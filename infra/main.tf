// Minimal simulation-first Terraform root
terraform {
  required_version = ">= 1.0.0"
}

variable "simulate" {
  description = "If true the modules will create local/no-op resources instead of real cloud resources."
  type        = bool
  default     = true
}

variable "project_name" {
  type    = string
  default = "swen-cloud-intel"
}

module "compute_aws" {
  source   = "./modules/simulated_compute"
  provider = "aws"
  name     = "${var.project_name}-aws"
  region   = "us-east-1"
  simulate = var.simulate
}

module "compute_alibaba" {
  source   = "./modules/simulated_compute"
  provider = "alibaba"
  name     = "${var.project_name}-alibaba"
  region   = "cn-hangzhou"
  simulate = var.simulate
}

output "simulated_resources" {
  value = {
    aws      = module.compute_aws.resources
    alibaba  = module.compute_alibaba.resources
  }
}
