output "resources" {
  description = "List of simulated resources created by this module"
  value       = var.simulate ? [for r in null_resource.sim_instance : {id = r.id, name = var.name, region = var.region}] : []
}
