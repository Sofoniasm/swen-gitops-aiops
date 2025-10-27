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

variable "enable_alibaba" {
  description = "When true the alibaba simulated/real module will be included. Default false because most devs won't have an Alibaba account."
  type        = bool
  default     = false
}

module "compute_aws" {
  source   = "./modules/simulated_compute"
  # If you set simulate = false and provide AWS credentials, this module can be replaced
  # with a provider-specific module that creates real AWS resources.
  name     = "${var.project_name}-aws"
  region   = "us-east-1"
  simulate = var.simulate
}

# Include Alibaba only when explicitly enabled (most users won't have Alibaba credentials)
module "compute_alibaba" {
  source   = "./modules/simulated_compute"
  count    = var.enable_alibaba ? 1 : 0
  name     = "${var.project_name}-alibaba"
  region   = "cn-hangzhou"
  simulate = var.simulate
}

output "simulated_resources" {
  value = {
    aws = module.compute_aws.resources
    alibaba = var.enable_alibaba && length(module.compute_alibaba) > 0 ? module.compute_alibaba[0].resources : []
  }
}
