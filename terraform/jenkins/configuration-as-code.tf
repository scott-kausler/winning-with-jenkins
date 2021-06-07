resource "kubernetes_config_map" "jenkins_operator_user_configuration" {
  metadata {
    name = "jenkins-operator-user-configuration"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
    "1-system-message.yaml"=<<EOF
  jenkins:
    globalNodeProperties:
      - envVars:
          env:
          - key: GITHUB_ORG
            value: ${var.github_org}
          - key: PIPELINE_LIBRARY_REPO_NAME
            value: ${var.pipeline_library_repo_name}
          - key: WORKSPACE
            value: ${terraform.workspace}
    authorizationStrategy:
      projectMatrix:
        permissions:
        - "Overall/Administer:jenkins-operator"
        - "Overall/Administer:anonymous"
    securityRealm:
      local:
        allowsSignup: false
        enableCaptcha: false
  credentials:
    system:
      domainCredentials:
      - credentials:
        - usernamePassword:
            description: "Github"
            id: "github-credentials"
            password: $${GITHUB_TOKEN}
            scope: GLOBAL
            username: ACCESSTOKEN
  unclassified:
    location:
      url: localhost:${random_integer.jenkins_node_port.result}
    globalLibraries:
      libraries:
      - defaultVersion: main
        name: "jenkins-pipeline-library"
        retriever:
          modernSCM:
            scm:
              git:
                id: "jenkins-pipeline-library"
                remote: "https://github.com/${var.github_org}/${var.pipeline_library_repo_name}.git"
                credentialsId: "github-credentials"
EOF
  }
}

resource "kubernetes_secret" "jenkins_conf_secrets" {
  metadata {
    name = "jenkins-conf-secrets"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
    GITHUB_TOKEN = var.github_token
  }
}