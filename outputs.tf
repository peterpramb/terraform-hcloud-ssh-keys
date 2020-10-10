# ====================================
# Manage SSH keys in the Hetzner Cloud
# ====================================


# ------------
# Local Values
# ------------

locals {
  output_ssh_keys = [
    for ssh_key in hcloud_ssh_key.ssh_keys : ssh_key
  ]
}


# -------------
# Output Values
# -------------

output "ssh_keys" {
  description = "A list of all SSH key objects."
  value       = local.output_ssh_keys
}

output "ssh_key_ids" {
  description = "A map of all SSH key objects indexed by ID."
  value       = {
    for ssh_key in local.output_ssh_keys : ssh_key.id => ssh_key
  }
}

output "ssh_key_names" {
  description = "A map of all SSH key objects indexed by name."
  value       = {
    for ssh_key in local.output_ssh_keys : ssh_key.name => ssh_key
  }
}
