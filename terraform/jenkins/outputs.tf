output "jenkins_url" {
    value = "localhost:${data.kubernetes_service.jenkins_http.spec.0.port.0.node_port}"
}