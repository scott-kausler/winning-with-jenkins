terraform {
  backend "kubernetes" {
    secret_suffix    = "jenkins"
  }
}

provider "kubernetes-alpha" {}