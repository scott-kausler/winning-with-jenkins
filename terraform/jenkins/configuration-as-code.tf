resource "kubernetes_config_map" "jenkins_operator_user_configuration" {
  metadata {
    name = "jenkins-operator-user-configuration"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
    "1-system-message.yaml"=<<EOF
  jenkins:
    authorizationStrategy:
      projectMatrix:
        permissions:
        - "Overall/Administer:jenkins-operator"
        - "Overall/Administer:anonymous"
    securityRealm:
      local:
        allowsSignup: false
        enableCaptcha: false
  unclassified:
    location:
      url: localhost:${random_integer.jenkins_node_port.result}
# credentials:
#   system:
#     domainCredentials:
#     - credentials:
#       - usernamePassword:
#           description: "Github creds"
#           id: "github_credentials"
#           password: {{ .Values.githubPassword }}
#           scope: GLOBAL
#           username: {{ .Values.githubUser }}
    #   - string:
    #       scope: GLOBAL
    #       id: slack-token
    #       secret: {{ .Values.slackToken }}
    #       description: Slack token
# unclassified:
#   slackNotifier:
#     teamDomain: ""
#     tokenCredentialId: slack-token
#     botUser: true
#     room: automated-deployments

#   globalLibraries:
#     libraries:
#     - defaultVersion: master
#       name: "lovevery-jenkins-pipeline-library"
#       defaultVersion: {{ .Values.branch }}
#       retriever:
#         modernSCM:
#           scm:
#             git:
#               id: "lovevery-jenkins-pipeline-library"
#               remote: "https://github.com/lovevery-digital/jenkins-pipeline-library.git"
#               credentialsId: "github_credentials"
EOF
  }
}

resource "kubernetes_secret" "jenkins_conf_secrets" {
  metadata {
    name = "jenkins-conf-secrets"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
  }
}