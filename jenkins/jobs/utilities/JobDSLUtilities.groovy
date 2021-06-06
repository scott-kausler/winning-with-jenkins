package utilities
class JobDSLUtilities {
    static createFolder(script, String githubRepo) {
        script.folder("${githubRepo}") {
            displayName("${githubRepo}")
            description("Folder for \"${githubRepo}\"")
        }
    }

    static createMultibranchPipelineJob(script, String githubOrg, String githubRepo) {

        def jobName="build"
        String jenkinsfile = "jenkins/pipelines/build-merge.jenkins"
        script.multibranchPipelineJob("${githubRepo}/${jobName}") {
            displayName("${jobName}")
            branchSources {
                branchSource {
                    source {
                        github {
                        //https://issues.jenkins.io/browse/JENKINS-43693
                        id(UUID.nameUUIDFromBytes("${githubRepo}/${jobName}".getBytes()).toString())
                        repoOwner(githubOrg)
                        repository("${githubRepo}")
                        credentialsId("github-credentials")
                        repositoryUrl("https://github.com/${githubOrg}/${githubRepo}.git")
                        configuredByUrl(false)
                        apiUri('https://api.github.com')
                        traits {
                            gitHubBranchDiscovery {
                                strategyId(2)
                            }
                            headWildcardFilter {
                                includes(branches)
                                excludes("")
                            }
                        }
                        }
                    }
                    buildStrategies {
                        buildAllBranches {
                            strategies {
                                skipInitialBuildOnFirstBranchIndexing()
                            }
                        }
                    }
                }
            }

            orphanedItemStrategy {
                discardOldItems {
                    daysToKeep(10)
                    numToKeep(10)
                }
            }

            // check every minute for scm changes as well as new / deleted branches
            triggers {
                periodic(1)
            }

            factory {
                workflowBranchProjectFactory {
                scriptPath(jenkinsfile)
                }
            }
        }
    }

    static createPipelineJob(script, String githubOrg, String githubRepo, String jobName="merge", String jenkinsfile="jenkins/pipelines/build-merge.jenkins") {
        script.pipelineJob("${githubRepo}/" + jobName) {
            displayName(jobName)
            parameters {
                stringParam( 'GIT_BRANCH', 'master', 'The branch name you are deploying from')
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