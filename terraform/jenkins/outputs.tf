output "jenkins_url" {
    value = "127.0.0.1:${random_integer.jenkins_node_port.result}"
}