# ====================================
# Manage SSH keys in the Hetzner Cloud
# ====================================


# -------------------
# Module Dependencies
# -------------------

terraform {
  required_version = ">= 0.13"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.20"
    }

    local  = {
      source  = "hashicorp/local"
      version = ">= 1.4"
    }

    tls    = {
      source  = "hashicorp/tls"
      version = ">= 2.1"
    }
  }
}
