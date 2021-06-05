terraform {
  backend "kubernetes" {
  }
}

provider "kubernetes-alpha" {}