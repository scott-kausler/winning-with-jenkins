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

    public static String getRepoName(script) {
        def tokens = script.env.GIT_URL.split("/")
        return tokens[4].substring(0, tokens[4].length() - 4)
    }

    public static String getOrgName(script) {
        def tokens = script.env.GIT_URL.split("/")
        return tokens[3]
    }

    public static String getOrgAndRepoName(script) {
        return getOrgName(script) + "/" + getRepoName(script)
    }

    public static String getPRNumber(script) {
        if(prNumber != null) {
            return prNumber;
        }

        script.withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PASS']]) {
            def githubOrgAndRepo=getOrgAndRepoName(script)
            def branch = getBranchName(script)

            def response = script.httpRequest(
                url: "https://api.github.com/repos/$githubOrgAndRepo/pulls?head=lovevery-digital:${branch}&state=open",
                acceptType: "APPLICATION_JSON",
                customHeaders: [[name: "Authorization", value: "token $script.GITHUB_PASS"]],
                validResponseCodes: "200,201"
            )

            def props = script.readJSON text: response.content
            if(props.length == 0) {
                return "-1"
            }
            return props[0].number
        }
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
        if(prNumber == "-1") {
            script.echo "No PR number. Cannot merge"
            return
        }

        if(!script.env.JOB_NAME.contains("/merge")) {
            script.echo "Can only merge merge jobs"
            return
        }

        def githubOrgAndRepo=getOrgAndRepoName(script)

        script.withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'github-credentials', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_PASS']]) {
            script.httpRequest(
                url: "https://api.github.com/repos/$githubOrgAndRepo/pulls/${prNumber}/merge",
                customHeaders: [[name: "Authorization", value: "token $script.GITHUB_PASS"]],
                contentType: "APPLICATION_JSON",
                requestBody: '{"merge_method": "squash"}',
                httpMode: "PUT",
                validResponseCodes: "200,201"
            )
        }
    }
}