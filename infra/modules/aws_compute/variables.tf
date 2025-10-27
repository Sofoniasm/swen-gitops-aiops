variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Optional SSH key name (leave empty to disable SSH access)"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port the demo app listens on (e.g., Streamlit 8501)"
  type        = number
  default     = 8501
}

variable "subnet_id" {
  description = "Optional subnet id to launch the instance into. If empty the module will try to use a default subnet or create one."
  type        = string
  default     = ""
}
