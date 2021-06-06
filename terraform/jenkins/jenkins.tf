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
            ]
        }
        "seedJobs" = [
          {
            "id" = "jenkins"
            "credentialType" = "usernamePassword"
            "credentialID" = "github-credentials"
            "targets" = <<EOF
jenkins/jobs/*.jenkins
jenkins/jobs/${terraform.workspace}/*.jenkins
EOF
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
    kubernetes_deployment.jenkins_operator
  ]
}