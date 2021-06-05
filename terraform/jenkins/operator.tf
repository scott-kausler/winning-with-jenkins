resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "${terraform.workspace}-jenkins"
  }
}

resource "kubernetes_deployment" "jenkins_operator" {
  metadata {
    name = local.jenkins_operator
    namespace = kubernetes_namespace.jenkins.id
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = local.jenkins_operator
      }
    }

    template {
      metadata {
        labels = {
          name = local.jenkins_operator
        }
      }

      spec {
        service_account_name = local.jenkins_operator
        container {
          image = "virtuslab/jenkins-operator:${var.operator_version}"
          name  = local.jenkins_operator
          command = [ "jenkins-operator" ]
          image_pull_policy = "IfNotPresent"
          env {
            name = "OPERATOR_NAME"
            value = local.jenkins_operator
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "WATCH_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    null_resource.jenkins_crd,
    null_resource.jenkins_image_crd
  ]
}

resource "kubernetes_service_account" "jenkins_operator" {
  metadata {
    name = local.jenkins_operator
    namespace = kubernetes_namespace.jenkins.id
  }
}

resource "kubernetes_role_binding" "jenkins_operator" {
  metadata {
    name = local.jenkins_operator
    namespace = kubernetes_namespace.jenkins.id
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.jenkins_operator
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.jenkins_operator
    namespace = kubernetes_namespace.jenkins.id
  }
}

resource "kubernetes_role" "jenkins_operator" {
  metadata {
    name = local.jenkins_operator
    namespace = kubernetes_namespace.jenkins.id
  }

  rule {
      api_groups = [
        "",
      ]
      resources = [
        "services",
        "configmaps",
        "secrets",
        "serviceaccounts",
      ]
      verbs = [
        "get",
        "create",
        "update",
        "list",
        "watch",
      ]
  }
  rule {
      api_groups = [
        "apps",
      ]
      resources = [
        "deployments",
        "daemonsets",
        "replicasets",
        "statefulsets",
      ]
      verbs = [
        "*",
      ]
    }
  rule {
      api_groups = [
        "rbac.authorization.k8s.io",
      ]
      resources = [
        "roles",
        "rolebindings",
      ]
      verbs = [
        "create",
        "update",
        "list",
        "watch",
      ]
    }
  rule {
      api_groups = [
        "",
      ]
      resources = [
        "pods/portforward",
      ]
      verbs = [
        "create",
      ]
    }
  rule {
      api_groups = [
        "",
      ]
      resources = [
        "pods/log",
      ]
      verbs = [
        "get",
        "list",
        "watch",
      ]
    }
  rule {
      api_groups = [
        "",
      ]
      resources = [
        "pods",
        "pods/exec",
      ]
      verbs = [
        "*",
      ]
    }
  rule {
      api_groups = [
        "",
      ]
      resources = [
        "events",
      ]
      verbs = [
        "watch",
        "list",
        "create",
        "patch",
      ]
    }
  rule {
      api_groups = [
        "apps",
      ]
      resource_names = [
        local.jenkins_operator,
      ]
      resources = [
        "deployments/finalizers",
      ]
      verbs = [
        "update",
      ]
    }
  rule {
      api_groups = [
        "jenkins.io",
      ]
      resources = [
        "*",
      ]
      verbs = [
        "*",
      ]
    }
  rule {
      api_groups = [
        "",
      ]
      resources = [
        "persistentvolumeclaims",
      ]
      verbs = [
        "get",
        "list",
        "watch",
      ]
    }
  rule {
      api_groups = [
        "route.openshift.io",
      ]
      resources = [
        "routes",
      ]
      verbs = [
        "get",
        "list",
        "watch",
        "create",
        "update",
      ]
    }
  rule {
      api_groups = [
        "image.openshift.io",
      ]
      resources = [
        "imagestreams",
      ]
      verbs = [
        "get",
        "list",
        "watch",
      ]
    }
  rule {
      api_groups = [
        "build.openshift.io",
      ]
      resources = [
        "builds",
        "buildconfigs",
      ]
      verbs = [
        "get",
        "list",
        "watch",
      ]
    }
}