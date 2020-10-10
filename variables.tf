# ====================================
# Manage SSH keys in the Hetzner Cloud
# ====================================


# ---------------
# Input Variables
# ---------------

variable "ssh_keys" {
  description = "The list of SSH key objects to be managed. Each key object supports the following parameters: 'name' (string, required), 'algorithm' (string, optional), 'key_param' (string, optional), 'public_key' (string, optional), 'labels' (map of KV pairs, optional)."

  type        = list(
    object({
      name       = string
      algorithm  = string
      key_param  = string
      public_key = string
      labels     = map(string)
    })
  )

  default     = [
    {
      name       = "ssh-key-1"
      algorithm  = null
      key_param  = null
      public_key = "~/.ssh/id_rsa.pub"
      labels     = {}
    }
  ]

  validation {
    condition     = can([
      for ssh_key in var.ssh_keys : regex("\\w+", ssh_key.name)
    ])
    error_message = "All SSH keys must have a valid 'name' attribute specified."
  }
}

variable "ssh_key_path" {
  description = "The destination path for generated SSH key files. Defaults to '~/.ssh'."
  type        = string
  default     = "~/.ssh"
}

variable "ssh_key_path_perms" {
  description = "The permissions for the SSH key destination path. Defaults to '0700'."
  type        = string
  default     = "0700"
}

variable "ssh_private_key_perms" {
  description = "The permissions for generated SSH private key files. Defaults to '0600'."
  type        = string
  default     = "0600"
}

variable "ssh_public_key_perms" {
  description = "The permissions for generated SSH public key files. Defaults to '0640'."
  type        = string
  default     = "0640"
}
