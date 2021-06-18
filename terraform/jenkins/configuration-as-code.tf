locals {
  local_security_realm=<<EOF
    securityRealm:
      local:
        allowsSignup: false
        enableCaptcha: false
EOF

  github_security_realm=<<EOF
    securityRealm:
      github:
        githubWebUri: "https://github.com"
        githubApiUri: "https://api.github.com"
        clientID: ${var.github_oauth_client_id}
        clientSecret: ${var.github_oauth_client_secret}
        oauthScopes: read:org,user:email
EOF

  security_realm = var.github_oauth_client_id == null || var.github_oauth_client_id == "" ? local.local_security_realm : local.github_security_realm
}

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
          - key: JENKINS_BASE_HOST
            value: 127.0.0.1:${random_integer.jenkins_node_port.result}
    authorizationStrategy:
      projectMatrix:
        permissions:
        - "Overall/Administer:${var.administrator_user}"
${local.security_realm}
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
      url: 127.0.0.1:${random_integer.jenkins_node_port.result}
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