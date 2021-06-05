resource "null_resource" "jenkins_crd" {
  triggers = {
    file = filesha256("${path.module}/jenkins.io_jenkins_crd.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply --context=$KUBE_CTX -f ${path.module}/jenkins.io_jenkins_crd.yaml"
  }
}

resource "null_resource" "jenkins_image_crd" {
  triggers = {
    file = filesha256("${path.module}/jenkins.io_jenkinsimages_crd.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply --context=$KUBE_CTX -f ${path.module}/jenkins.io_jenkinsimages_crd.yaml"
  }
}