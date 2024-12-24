
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

module "vpc" {
  source = "./vpc.tf"
}

module "iam" {
  source = "./iam.tf"
}

module "eks" {
  source = "./eks.tf"
}

