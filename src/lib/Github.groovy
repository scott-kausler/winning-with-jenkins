package lib

class Github implements Serializable {

    // These is effectively a cache
    private static String prNumber = null
    private static String currentBranch = null

    public static String getBranchName(script) {
        if(currentBranch != null) {
            return currentBranch
        }
        def branch = script.env.GIT_BRANCH
        if (branch == null || branch.allWhitespace) {
            branch = script.BRANCH_NAME
        }

        if ( branch == null || branch.allWhitespace ){
            branch = "main"
        }
        currentBranch = branch.replaceAll("origin/","")
        return currentBranch
    }

    public static String getOrgAndRepoName(script) {
      return script.sh(script: """
        ORIGINAL_GIT_URL=$script.GIT_URL
        GIT_URL_WITHOUT_SUFFIX=\${ORIGINAL_GIT_URL%.*}
        GITHUB_ORG_REPO=\${GIT_URL_WITHOUT_SUFFIX#*https://github.com/}
        printf "\$GITHUB_ORG_REPO"
      """, returnStdout: true)
    }

    public static String getPRNumber(script) {
        if(prNumber != null) {
            return prNumber;
        }

        script.withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PASS']]) {
        def githubOrgAndRepo=getOrgAndRepoName(script)
        def branch = getBranchName(script)

        prNumber=script.sh(script: """
            URL="https://api.github.com/repos/$githubOrgAndRepo/pulls?head=lovevery-digital:${branch}&state=open"
            #remove whitespace
            URL=\$(echo \$URL)
            curl -s -f -H "Authorization: token $script.GITHUB_PASS" "\$URL" > pr.json
            PR_COUNT=\$(jq -r length pr.json)
            if [ "\$PR_COUNT" != "1" ]; then
                echo "-1"
            else
                PR_NUMBER=\$(jq -rj '.[0].number' pr.json)
                echo "\$PR_NUMBER"
            fi
        """, returnStdout: true).replaceAll("\\s", "")
        }

        return prNumber;
    }

    public static void addStatusCheck(script, contextSuffix, description, url) {
        if(!script.env.JOB_NAME.contains("/build")){
            script.echo "Can only add PR status in build jobs."
            return
        }
        script.githubNotify(description: description, context: 'jenkins/' + contextSuffix, targetUrl: url, status: 'SUCCESS')
    }

    public static void addJenkinsJobTrigger(script, String jobName) {
        if(!script.env.JOB_NAME.contains("/build")){
            script.echo "Can only add PR status in build jobs."
            return
        }

        def branch=getBranchName(script)
        def encodedBranchName=java.net.URLEncoder.encode("$branch", "UTF-8")
        def repoName=getRepoName(script)

        String url = "${script.JENKINS_URL}job/$repoName/job/$jobName/parambuild?GIT_BRANCH=$encodedBranchName"
        String statusText = "Click Details button to go to $jobName job"

        addStatusCheck(script, "$jobName-job", statusText, url)
    }

    public static merge(script) {
        def prNumber = getPRNumber(script)
        if(prNumber == "-1"){
            script.echo "No PR number. Cannot merge"
            return
        }

        if(!script.env.JOB_NAME.contains("/merge")){
            script.echo "Can only merge merge jobs"
            return
        }

        def githubOrgAndRepo=getOrgAndRepoName(script)
        script.withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PASS']]) {
            script.sh(script: """
                URL="https://api.github.com/repos/${githubOrgAndRepo}/pulls/${prNumber}/merge"
                URL=\$(echo \$URL)
                curl -f -H "Authorization: token ${script.GITHUB_PASS}"  -X PUT -d '{"merge_method": "squash"}'  "\$URL"
            """)
        }
    }
}