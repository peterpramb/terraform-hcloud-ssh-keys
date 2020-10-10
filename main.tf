# ====================================
# Manage SSH keys in the Hetzner Cloud
# ====================================


# ------------
# Local Values
# ------------

locals {
  # Build a map of all provided SSH key objects, indexed by SSH key name:
  ssh_keys      = {
    for ssh_key in var.ssh_keys : ssh_key.name => ssh_key
  }

  # Build a map of all provided SSH key objects to be generated, indexed by
  # SSH key name:
  generate_keys = {
    for name, ssh_key in local.ssh_keys : name => merge(ssh_key, {
      rsa_bits         = ssh_key.algorithm == "RSA"   ? ssh_key.key_param : null
      ecdsa_curve      = ssh_key.algorithm == "ECDSA" ? ssh_key.key_param : null
      private_key_file = pathexpand(format("%s/%s",     var.ssh_key_path, name))
      public_key_file  = pathexpand(format("%s/%s.pub", var.ssh_key_path, name))
    }) if(try(ssh_key.algorithm, null) != null && ssh_key.algorithm != "")
  }

  # Build a map of all provided SSH key objects to be imported, indexed by
  # SSH key name:
  import_keys   = {
    for name, ssh_key in local.ssh_keys : name => merge(ssh_key, {
      public_key_file = pathexpand(ssh_key.public_key)
    }) if(try(ssh_key.public_key, null) != null && ssh_key.public_key != "" &&
         can(regex("^[/~]", trimspace(ssh_key.public_key))))
  }

  # Build a map of all provided SSH key objects to be used verbatim, indexed by
  # SSH key name:
  use_keys      = {
    for name, ssh_key in local.ssh_keys : name => ssh_key
      if(try(ssh_key.public_key, null) != null && ssh_key.public_key != "" &&
        can(regex("^[^/~]", trimspace(ssh_key.public_key))))
  }

  # Build a map of all resulting SSH key objects, indexed by SSH key name:
  combine_keys  = merge(
    {
      for name, ssh_key in local.generate_keys :
        name => chomp(tls_private_key.ssh_keys[ssh_key.name].public_key_openssh)
    },
    {
      for name, ssh_key in local.import_keys :
        name => chomp(data.local_file.ssh_public_keys[ssh_key.name].content)
    },
    {
      for name, ssh_key in local.use_keys :
        name => trimspace(ssh_key.public_key)
    }
  )
}


# --------
# Generate
# --------

resource "tls_private_key" "ssh_keys" {
  for_each    = local.generate_keys

  algorithm   = each.value.algorithm
  rsa_bits    = each.value.rsa_bits
  ecdsa_curve = each.value.ecdsa_curve
}

resource "local_file" "ssh_private_keys" {
  for_each             = local.generate_keys

  sensitive_content    = tls_private_key.ssh_keys[each.key].private_key_pem
  filename             = each.value.private_key_file
  file_permission      = var.ssh_private_key_perms
  directory_permission = var.ssh_key_path_perms
}

resource "local_file" "ssh_public_keys" {
  for_each             = local.generate_keys

  content              = tls_private_key.ssh_keys[each.key].public_key_openssh
  filename             = each.value.public_key_file
  file_permission      = var.ssh_public_key_perms
  directory_permission = var.ssh_key_path_perms
}


# ------
# Import
# ------

data "local_file" "ssh_public_keys" {
  for_each = local.import_keys

  filename = each.value.public_key_file
}


# --------
# SSH Keys
# --------

resource "hcloud_ssh_key" "ssh_keys" {
  for_each   = local.combine_keys

  name       = each.key
  public_key = each.value

  labels     = local.ssh_keys[each.key].labels
}
