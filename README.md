[![License](https://img.shields.io/github/license/peterpramb/terraform-hcloud-ssh-keys)](https://github.com/peterpramb/terraform-hcloud-ssh-keys/blob/master/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/peterpramb/terraform-hcloud-ssh-keys?sort=semver)](https://github.com/peterpramb/terraform-hcloud-ssh-keys/releases/latest)
[![Terraform Version](https://img.shields.io/badge/terraform-%E2%89%A5%200.13.0-623ce4)](https://www.terraform.io)


# terraform-hcloud-ssh-keys

[Terraform](https://www.terraform.io) module for managing SSH keys in the [Hetzner Cloud](https://www.hetzner.com/cloud), with support for generating new SSH keys and importing existing SSH public keys.

It implements the following [provider](#providers) resources:

- [hcloud\_ssh\_key](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key)
- [local\_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)
- [local\_sensitive\_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file)
- [tls\_private\_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)

:warning: **WARNING**: SSH private keys will be stored unencrypted in the [Terraform state](https://www.terraform.io/docs/state). Using generated SSH keys in production deployments is therefore not recommended. Instead, create and distribute SSH keys outside of Terraform and just import the SSH public keys into Terraform.


## Usage

```terraform
module "ssh_key" {
  source   = "github.com/peterpramb/terraform-hcloud-ssh-keys?ref=<release>"

  ssh_keys = [
    {
      name       = "ssh-gen-1"
      algorithm  = "ECDSA"
      key_param  = "P256"
      public_key = null
      labels     = {
        "managed"    = "true"
        "managed_by" = "Terraform"
      }
    },
    {
      name       = "ssh-gen-2"
      algorithm  = "RSA"
      key_param  = "4096"
      public_key = null
      labels     = {
        "managed"    = "true"
        "managed_by" = "Terraform"
      }
    },
    {
      name       = "ssh-imp-1"
      algorithm  = null
      key_param  = null
      public_key = "~/.ssh/cloud-infra.pub"
      labels     = {
        "managed"    = "true"
        "managed_by" = "Terraform"
      }
    },
    {
      name       = "ssh-imp-2"
      algorithm  = null
      key_param  = null
      public_key = "ecdsa-sha2-nistp256 AAAAE2VjZH..."
      labels     = {
        "managed"    = "true"
        "managed_by" = "Terraform"
      }
    }
  ]
}
```


## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io) | &ge; 0.13 |


## Providers

| Name | Version |
|------|---------|
| [hcloud](https://registry.terraform.io/providers/hetznercloud/hcloud) | &ge; 1.20 |
| [local](https://registry.terraform.io/providers/hashicorp/local) | &ge; 2.2 |
| [tls](https://registry.terraform.io/providers/hashicorp/tls) | &ge; 2.1 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| ssh\_keys | List of SSH key objects to be managed. | list(map([*ssh\_key*](#ssh_key))) | See [below](#defaults) | yes |
| ssh\_key\_path | Destination path for generated SSH key files. | string | `"~/.ssh"` | no |
| ssh\_key\_path\_perms | Permissions for the SSH key destination path. | string | `"0700"` | no |
| ssh\_private\_key\_perms | Permissions for generated SSH private key files. | string | `"0600"` | no |
| ssh\_public\_key\_perms | Permissions for generated SSH public key files. | string | `"0640"` | no |


#### *ssh\_key*

| Name | Description | Type | Required |
|------|-------------|:----:|:--------:|
| [name](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key#name) | Unique name of the SSH key. | string | yes |
| [algorithm](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#algorithm) | Key algorithm for generated SSH keys. | string | yes (generate only) |
| key\_param | [RSA key size](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#rsa_bits) or [elliptic curve name](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#ecdsa_curve). | string | no |
| [public\_key](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key#public_key) | Absolute path to SSH public key file or SSH public key data. | string | yes (import only) |
| [labels](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key#labels) | Map of user-defined labels. | map(string) | no |


### Defaults

```terraform
ssh_keys = [
  {
    name       = "ssh-key-1"
    algorithm  = null
    key_param  = null
    public_key = "~/.ssh/id_rsa.pub"
    labels     = {}
  }
]
```


## Outputs

| Name | Description |
|------|-------------|
| ssh\_keys | List of all SSH key objects. |
| ssh\_key\_ids | Map of all SSH key objects indexed by ID. |
| ssh\_key\_names | Map of all SSH key objects indexed by name. |


### Defaults

```terraform
ssh_keys = [
  {
    "fingerprint" = "32:1e:71:8f:03:34..."
    "id" = "2173651"
    "labels" = {}
    "name" = "ssh-key-1"
    "public_key" = "ssh-rsa AAAAB3NzaC..."
  },
]

ssh_key_ids = {
  "2173651" = {
    "fingerprint" = "32:1e:71:8f:03:34..."
    "id" = "2173651"
    "labels" = {}
    "name" = "ssh-key-1"
    "public_key" = "ssh-rsa AAAAB3NzaC..."
  }
}

ssh_key_names = {
  "ssh-key-1" = {
    "fingerprint" = "32:1e:71:8f:03:34..."
    "id" = "2173651"
    "labels" = {}
    "name" = "ssh-key-1"
    "public_key" = "ssh-rsa AAAAB3NzaC..."
  }
}
```


## License

This module is released under the [MIT](https://github.com/peterpramb/terraform-hcloud-ssh-keys/blob/master/LICENSE) License.
