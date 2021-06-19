variable "github_org" {
    type = string
}

variable "pipeline_library_repo_name" {
    type = string
}


variable "administrator_user" {
    type = string
    default = "anonymous"
}

variable "github_token" {
    type = string
    sensitive = true
}

variable "github_oauth_client_id" {
    type = string
    default = ""
}

variable "github_oauth_client_secret" {
    type = string
    sensitive = true
    default = ""
}


locals {
    jenkins_operator = "jenkins-operator"
    operator_version = "v0.5.0"
}