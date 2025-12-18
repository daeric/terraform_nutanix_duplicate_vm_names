# terraform_nutanix_duplicate_vm_names

Terraform configuration to create a Nutanix VM while preventing duplicate VM names in Prism Central.

This repository contains a small Terraform configuration that:

- Looks up existing VMs by name in Prism Central.
- If no VM with the requested name exists, creates a VM using the Nutanix provider and a cloud-init user-data file.
- If a VM with the same name already exists, the apply is intentionally failed by a local-exec provisioner to avoid accidental duplicates.

## Contents

- `providers.tf` - provider configuration and required providers.
- `main.tf` - resources and data sources (cluster, image, subnet, VM creation, duplicate-name protection).
- `variables.tf` - variable declarations.
- `terraform.tfvars` - example variable values (DO NOT commit secrets in production).
- `files/config.yaml` - cloud-init user-data template used by the VM guest customization.

## Prerequisites

- Terraform (recommended 1.0+). The configuration pins the `nutanix/nutanix` provider to `2.2.3` in `providers.tf`.
- Network access to Prism Central / Nutanix endpoints referenced in `terraform.tfvars`.
- Credentials for Prism Central or NDB where appropriate.

## Variables

The configuration defines the following variables (see `variables.tf`):

- `pc_endpoint` - Prism Central endpoint (string)
- `pc_username` - Prism Central username (string)
- `pc_password` - Prism Central password (sensitive)
- `foundation_endpoint` - Foundation endpoint (optional)
- `foundation_port` - Foundation port (optional)
- `ndb_endpoint` - NDB endpoint (optional)
- `ndb_username` - NDB username (optional)
- `ndb_password` - NDB password (optional)
- `vm_name` - Name of the VM to create (string)

You can set variables with a `terraform.tfvars` file (this repo includes an example) or using environment variables or CLI flags.

Security note: do not commit real credentials to GitHub. Use environment variables, a secrets manager, or a separate excluded `.tfvars` file.

## How duplicate name prevention works

1. A data source `nutanix_virtual_machines_v2.existing` queries Prism Central for VMs with the requested `vm_name`.
2. If any matches are found, the `null_resource.prevent_duplicate_vm_name` resource is created and runs a `local-exec` that prints an error and exits with a non-zero status, causing the apply to fail.
3. The VM resource `nutanix_virtual_machine_v2.test` uses `count` to only be created when no existing VM is found.

This is a safety-first pattern to avoid accidentally creating two VMs with the same name.
