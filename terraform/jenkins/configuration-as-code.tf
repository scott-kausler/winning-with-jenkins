resource "kubernetes_config_map" "jenkins_operator_user_configuration" {
  metadata {
    name = "jenkins-operator-user-configuration"
    namespace = kubernetes_namespace.jenkins.id
  }
  data = {
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