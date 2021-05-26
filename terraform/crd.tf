resource "null_resource" "jenkins_crds" {
  provisioner "local-exec" {
    command = "kubectl apply --context=$KUBE_CTX -f https://raw.githubusercontent.com/jenkinsci/kubernetes-operator/${var.operator_version}/deploy/crds/jenkins_v1alpha2_jenkins_crd.yaml"
  }
}