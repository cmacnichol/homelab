variable "proxmox" {
  type = object({
    name         = string
    cluster_name = string
    endpoint     = string
    insecure     = bool
    username     = string
    api_token    = string
  })
  sensitive = true
}

/* variable "proxmox_nodes" {
  description = "ProxMox Node Configuration"
  type = object({
    node_name = string
    endpoint = string
    api_token = string
    default = optional(bool, false)
    insecure = optional(bool, true)
    username = optional(string, "root")
  })
  validation {
    condition = length([for node in var.proxmox_nodes : node if node.default == true]) == 1
    error_message = "Only one node can have 'default = true'."
  }
  sensitive = true
} */

# Storage Variable for Disk and Img Creation
variable "storage" {
  type = object({
    storage_name = string
    imgstor_name = string
    shared_stor  = bool
  })
  sensitive = false
}

variable "key_file" {
  type  = string
  default   = "/root/.ssh/id_ed25519"
  description = "Private Key File for ProxMox"
  sensitive = false
}

#variable "cluster_config" {
#  description = "Talos node configuration"
#  type = object({
#
#    cluster_name    = string
#    proxmox_cluster = string
#    endpoint        = string
#    talos_version   = string
#
#    nodes = map(
#      object({
#        host_node     = string
#        machine_type  = string
#        ip            = string
#        mac_address   = string
#        vm_id         = number
#        cpu           = number
#        ram_dedicated = number
#        update = optional(bool, false)
#        igpu = optional(bool, false)
#      })
#    )
#  })
#
#  validation {
#    condition     = length([
#      for n in var.cluster_config.nodes : n if contains(["controlplane", "worker"], n.machine_type)]) == length(var.cluster_config.nodes)
#    error_message = "Node machine_type must be either 'controlplane' or 'worker'."
#  }
#}
#
#variable "volumes" {
#  type = map(
#    object({
#      node = string
#      size = string
#      storage = optional(string, "local-zfs")
#      vmid = optional(number, 9999)
#      format = optional(string, "raw")
#    })
#  )
#}
