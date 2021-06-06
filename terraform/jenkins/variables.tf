variable "github_org" {
    type = string
}

variable "pipeline_library_repo_name" {
    type = string
}

variable "github_token" {
    type = string
    sensitive = true
}

locals {
    jenkins_operator = "jenkins-operator"
    operator_version = "v0.5.0"
}