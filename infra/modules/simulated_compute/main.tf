locals {
  instance_count = 1
}

// When simulate = true we create null_resources to represent compute instances
resource "null_resource" "sim_instance" {
  count = var.simulate ? local.instance_count : 0
  triggers = {
    name   = var.name
    region = var.region
  }
}

// When simulate = false, user should add provider-specific resources in a separate real module
