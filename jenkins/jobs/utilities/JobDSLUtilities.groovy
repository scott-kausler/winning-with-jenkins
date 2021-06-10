package utilities
class JobDSLUtilities {
    static createFolder(script, String githubRepo) {
        script.folder("${githubRepo}") {
            displayName("${githubRepo}")
            description("Folder for \"${githubRepo}\"")
        }
    }

    static createPipelineJob(script, String githubOrg, String githubRepo, String jobName="merge", String jenkinsfile="jenkins/pipelines/build-merge.jenkins") {
        script.pipelineJob("${githubRepo}/" + jobName) {
            displayName(jobName)
            parameters {
                stringParam( 'GIT_BRANCH', 'main', 'The branch name you are deploying from')
            }
            logRotator {
                numToKeep(10)
                daysToKeep(30)
            }
            definition {
                cpsScm {
                    scm {
                        git {
                            remote {
                                url("https://github.com/${githubOrg}/${githubRepo}.git")
                                credentials("github-credentials")
                            }
                            branches('${GIT_BRANCH}')
                        }
                    }
                    scriptPath(jenkinsfile)
                }
            }
        }
    }
}