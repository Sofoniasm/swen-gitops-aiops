variable "name" {
  description = "Base name for simulated resources"
  type        = string
}

variable "region" {
  description = "Region for the simulated resources"
  type        = string
}

variable "simulate" {
  description = "Run in simulation mode (create null_resource)"
  type        = bool
  default     = true
}
