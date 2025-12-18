data "nutanix_clusters_v2" "Test" {
  filter = "name eq 'Test'"
}

data "nutanix_images_v2" "rocky" {
  filter = "startswith(name,'rocky')"
  page   = 0
  limit  = 10
}

data "nutanix_subnets_v2" "default" {
  filter = "name eq 'default'"
}

data "nutanix_virtual_machines_v2" "existing" {
  filter = "name eq '${var.vm_name}'"
  page   = 0
  limit  = 1
}

resource "nutanix_virtual_machine_v2" "test" {
  count                = length(data.nutanix_virtual_machines_v2.existing.vms) == 0 ? 1 : 0
  name                 = var.vm_name
  num_sockets          = 1
  num_cores_per_socket = 4
  memory_size_bytes    = 8 * 1024 * 1024 * 1024 # 8 GiB

  cluster {
    ext_id = data.nutanix_clusters_v2.Test.cluster_entities[0].ext_id
  }

  guest_customization {
    config {
      cloud_init {
        cloud_init_script {
          user_data {
            value = base64encode(templatefile("${path.module}/files/config.yaml", { vm_name = var.vm_name }))
          }
        }
      }
    }
  }

  disks {
    disk_address {
      bus_type = "SCSI"
      index    = 0
    }
    backing_info {
      vm_disk {
        data_source {
          reference {
            image_reference {
              image_ext_id = data.nutanix_images_v2.rocky.images[0].ext_id
            }
          }
        }
      }
    }
  }

  nics {
    network_info {
      nic_type = "NORMAL_NIC"
      subnet {
        ext_id = data.nutanix_subnets_v2.default.subnets[0].ext_id
      }
      vlan_mode = "ACCESS"
    }
  }

  power_state = "ON"
}

# If the data lookup finds any VMs with the requested name, this
# null_resource will run a local command that exits non-zero and causes the apply to fail.
resource "null_resource" "prevent_duplicate_vm_name" {
  count = length(data.nutanix_virtual_machines_v2.existing.vms) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo \"ERROR: VM with name '${var.vm_name}' already exists in Prism Central. Aborting.\" 1>&2 && exit 1"
  }
}