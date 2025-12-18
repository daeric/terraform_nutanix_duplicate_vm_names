# terraform_nutanix_duplicate_vm_names

This Terraform configuration creates a Nutanix AHV virtual machine using the `nutanix` provider (v2.x). It includes a cloud-init guest-customization payload and a guard that detects duplicate VM names in Prism Central. Unlike the `*_suffix` example workflow, this repository intentionally prevents creation when a name collision is detected (the apply is aborted).

## What this repo does

- Creates a VM from an image discovered via `data "nutanix_images_v2"`.
- Attaches a NIC using a subnet discovered via `data "nutanix_subnets_v2"`.
- Supplies cloud-init user data from `files/config.yaml` (rendered with the requested VM name).
- If a VM with the requested name already exists in Prism Central, Terraform intentionally aborts the apply to avoid creating two VMs with the same name.

## Contents

- `main.tf` - primary Terraform configuration (data sources, VM resource, cloud-init embedding, and duplicate-name guard).
- `providers.tf` - provider configuration and required providers.
- `variables.tf` / `terraform.tfvars` - variable declarations and example values.
- `files/config.yaml` - cloud-init template used for guest customization (expects a `vm_name` variable).

## Requirements

- Terraform 1.0+ (this workspace used Terraform 1.x during development).
- Nutanix Prism Central reachable from the machine running Terraform.
- The `nutanix/nutanix` provider (pinned in `providers.tf`), and `hashicorp/null` for the guard.

##How duplicate names are handled

This config uses a data source `nutanix_virtual_machines_v2.existing` to query Prism Central for any VM that matches the requested `vm_name`.

- If no existing VM is found, the VM resource `nutanix_virtual_machine_v2.test` is created (the resource uses `count = 1` in that case).
- If one or more matches are found, a `null_resource.prevent_duplicate_vm_name` is created which runs a `local-exec` that prints an error message and exits non-zero. That causes the `terraform apply` to fail and prevents VM creation.

Rationale: this is a safety-first approach. It avoids mid-create collisions and forces an operator decision when a name is already present in Prism Central.
