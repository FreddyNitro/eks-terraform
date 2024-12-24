
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

module "vpc" {
  path = "./vpc.tf"
}

module "iam" {
  path = "./iam.tf"
}

module "eks" {
  path = "./eks.tf"
}

