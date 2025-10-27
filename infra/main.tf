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

// Conditional inclusion: simulated_aws is used when simulate=true; aws_compute is used when simulate=false

module "simulated_aws" {
  source   = "./modules/simulated_compute"
  count    = var.simulate ? 1 : 0
  name     = "${var.project_name}-aws"
  region   = "us-east-1"
  simulate = var.simulate
}

module "aws_compute" {
  source        = "./modules/aws_compute"
  count         = var.simulate ? 0 : 1
  name          = "${var.project_name}-aws"
  region        = "us-east-1"
  instance_type = "t2.micro"
  app_port      = 8501
}

# Include Alibaba only when explicitly enabled (most users won't have Alibaba credentials)
module "compute_alibaba" {
  source   = "./modules/simulated_compute"
  count    = var.enable_alibaba ? 1 : 0
  name     = "${var.project_name}-alibaba"
  region   = "cn-hangzhou"
  simulate = var.simulate
}

output "aws_simulated_resources" {
  value = var.simulate && length(module.simulated_aws) > 0 ? module.simulated_aws[0].resources : []
}

output "aws_instance_id" {
  value = var.simulate ? "" : (length(module.aws_compute) > 0 ? module.aws_compute[0].instance_id : "")
}

output "aws_instance_public_ip" {
  value = var.simulate ? "" : (length(module.aws_compute) > 0 ? module.aws_compute[0].public_ip : "")
}
