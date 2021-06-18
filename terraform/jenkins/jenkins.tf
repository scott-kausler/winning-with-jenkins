data "kubernetes_service" "jenkins_http" {
  metadata {
    name = "jenkins-operator-http-jenkins"
    namespace = kubernetes_namespace.jenkins.id
  }
  depends_on = [
    kubernetes_manifest.jenkins
  ]
}

resource "random_integer" "jenkins_node_port" {
  min = 30000
  max = 32767
  seed = terraform.workspace
}

// Set gethub secret as operator credentials to enable github ouath
resource "kubernetes_secret" "jenkins_operator_credentials" {
  metadata {
    name = "jenkins-operator-credentials-jenkins"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
    user = "ACCESSTOKEN"
    password = var.github_token
    token = var.github_token
    // By setting this in the future we tell the operator not to rotate these credentials
    tokenCreationTime = "2031-02-27T14:56:56.524250355Z"
  }
}

resource "kubernetes_secret" "github_credentials" {
  metadata {
    name = "github-credentials"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
    username = "ACCESSTOKEN"
    password = var.github_token
  }
}

resource "kubernetes_manifest" "jenkins" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "jenkins.io/v1alpha2"
    "kind" = "Jenkins"
    "metadata" = {
        "name" = "jenkins"
        "namespace" = kubernetes_namespace.jenkins.id
    }
    "spec" = {
        "service" = {
            "type" = "NodePort"
            "port" = 8080
            "nodePort" = random_integer.jenkins_node_port.result
        }
        "configurationAsCode" = {
          "configurations" = [
              {
                  "name" = kubernetes_config_map.jenkins_operator_user_configuration.metadata.0.name
              }
          ]
          "secret" = {
            "name" = kubernetes_secret.jenkins_conf_secrets.metadata.0.name
          }
        }
        "groovyScripts" = {
          "configurations" = [
              {
                  "name" = kubernetes_config_map.jenkins_operator_user_configuration.metadata.0.name
              }
          ]
          "secret" = {
            "name" = kubernetes_secret.jenkins_conf_secrets.metadata.0.name
          }
        }
        "master" = {
            "containers" = [{
              "name" = "jenkins-master"
              "image" = "jenkins/jenkins:2.289.1-lts-alpine"
              "imagePullPolicy" = "IfNotPresent"
              "resources" = {
                "requests" ={
                  "cpu" = "250m"
                  "memory" = "500Mi"
                }
                "limits" = {
                  "cpu" = "1500m"
                  "memory" = "3Gi"
                }
              }
            }]
            "disableCSRFProtection": false
            "basePlugins" = [
                {
                    "name" = "kubernetes"
                    "version" = "1.29.6"
                },
                {
                    "name" = "workflow-job"
                    "version" = "2.41"
                },
                {
                    "name" = "workflow-aggregator"
                    "version" = "2.6"
                },
                {
                    "name" = "git-client"
                    "version" = "3.7.2"
                },
                {
                    "name" = "git"
                    "version" = "4.7.2"
                },
                {
                    "name" = "job-dsl"
                    "version" = "1.77"
                },
                {
                    "name" = "configuration-as-code"
                    "version" = "1.51"
                },
                {
                    "name" = "kubernetes-client-api"
                    "version" = "4.13.3-1"
                },
                {
                    "name" = "kubernetes-credentials-provider"
                    "version" = "0.18-1"
                }
            ]
            "plugins" = [
                {
                    "name" = "credentials"
                    "version" = "2.5"
                },
                {
                    "name" = "github-branch-source"
                    "version" = "2.11.1"
                },
                {
                    "name" = "build-with-parameters"
                    "version" = "1.5.1"
                },
                {
                    "name" = "slack"
                    "version" = "2.45"
                },
                {
                    "name" = "pipeline-githubnotify-step"
                    "version" = "1.0.5"
                },
                {
                    "name" = "matrix-auth"
                    "version" = "2.6.7"
                },
                {
                    "name" = "pipeline-utility-steps"
                    "version" = "2.8.0"
                },
                {
                    "name" = "http_request"
                    "version" = "1.9.0"
                },
                {
                    "name" = "github-oauth"
                    "version" = "0.33"
                },
            ]
        }
        "seedJobs" = [
          {
            "id" = "jenkins-default"
            "credentialType" = "usernamePassword"
            "credentialID" = "github-credentials"
            "ignoreMissingFiles" = false
            "targets" = "jenkins/jobs/*.jenkins"
            "description" = "Seed Jobs"
            "repositoryBranch" = "main"
            "repositoryUrl" = "https://github.com/${var.github_org}/${var.pipeline_library_repo_name}.git"
          },
          {
            "id" = "jenkins-workspace"
            "credentialType" = "usernamePassword"
            "credentialID" = "github-credentials"
            "ignoreMissingFiles" = true
            "targets" = "jenkins/jobs/${terraform.workspace}/*.jenkins"
            "description" = "Seed Jobs"
            "repositoryBranch" = "main"
            "repositoryUrl" = "https://github.com/${var.github_org}/${var.pipeline_library_repo_name}.git"
          }
        ]
    }
  }
  wait_for = {
    fields = {
      # Check the phase of a pod
      "status.baseConfigurationCompletedTime" = "\\d{4}.*"
    }
  }

  depends_on = [
    kubernetes_deployment.jenkins_operator,
    kubernetes_secret.jenkins_operator_credentials
  ]
}