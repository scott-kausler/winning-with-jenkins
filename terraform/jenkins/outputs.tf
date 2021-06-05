output "jenkins_url" {
    value = "localhost:${random_integer.jenkins_node_port.result}"
}