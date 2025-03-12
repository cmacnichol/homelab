module "talos" {
  source = "./talos"

  # Declaring to pass into the child module
  storage = {
    storage_name = var.storage.storage_name
    imgstor_name = var.storage.imgstor_name
    shared_stor  = var.storage.shared_stor
  }

  image = {
    version = "v1.9.2"
    update_version = "v1.9.3" # renovate: github-releases=siderolabs/talos
    schematic = file("${path.module}/talos/image/schematic.yaml")
    # Point this to a new schematic file to update the schematic
    update_schematic = file("${path.module}/talos/image/schematic.yaml")
    proxmox_datastore = var.storage.imgstor_name
  }

  cilium = {
    values = file("${path.module}/../../k8s/infra/network/cilium/values.yaml")
    install = file("${path.module}/talos/inline-manifests/cilium-install.yaml")
  }

  cluster = {
    name            = "talos"
    endpoint        = "192.168.80.100"
    gateway         = "192.168.80.1"
    talos_version   = "v1.8"
    proxmox_cluster = "homelab"
  }

  nodes = {
    "ctrl-00" = {
      host_node     = "pve"
      machine_type  = "controlplane"
      ip            = "192.168.80.100"
      dns           = ["1.1.1.1", "8.8.8.8"]
      mac_address   = "BC:24:11:2E:C8:00"
      vm_id         = 8000
      cpu           = 8
      ram_dedicated = 28672
      datastore_id  = "${var.storage.storage_name}"
    }
    "ctrl-01" = {
      host_node     = "prox"
      machine_type  = "controlplane"
      ip            = "192.168.80.101"
      mac_address   = "BC:24:11:2E:C8:01"
      vm_id         = 8001
      cpu           = 4
      ram_dedicated = 20480
      datastore_id  = "${var.storage.storage_name}"
      #update        = true
    }
    "ctrl-02" = {
      host_node     = "mox"
      machine_type  = "controlplane"
      ip            = "192.168.80.102"
      mac_address   = "BC:24:11:2E:C8:02"
      vm_id         = 8002
      cpu           = 4
      ram_dedicated = 4096
      datastore_id  = "${var.storage.storage_name}"
      #update        = true
    }
    "work-00" = {
      host_node     = "pve"
      machine_type  = "worker"
      ip            = "192.168.80.110"
      mac_address   = "BC:24:11:2E:A8:00"
      vm_id         = 8010
      cpu           = 8
      ram_dedicated = 4096
      igpu          = true
      datastore_id  = "${var.storage.storage_name}"
    }
    "work-01" = {
      host_node     = "prox"
      machine_type  = "worker"
      ip            = "192.168.80.111"
      mac_address   = "BC:24:11:2E:A8:01"
      vm_id         = 8011
      cpu           = 8
      ram_dedicated = 4096
      igpu          = true
      datastore_id  = "${var.storage.storage_name}"
    }
    "work-02" = {
      host_node     = "mox"
      machine_type  = "worker"
      ip            = "192.168.80.112"
      mac_address   = "BC:24:11:2E:A8:02"
      vm_id         = 8012
      cpu           = 8
      ram_dedicated = 4096
      igpu          = true
      datastore_id  = "${var.storage.storage_name}"
    }
  }

}

module "sealed_secrets" {
  depends_on = [module.talos]
  source = "./bootstrap/sealed-secrets"

  providers = {
    kubernetes = kubernetes
  }

  // openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout sealed-secrets.key -out sealed-secrets.crt -subj "/CN=sealed-secret/O=sealed-secret"
  cert = {
    cert = file("${path.module}/bootstrap/sealed-secrets/certificate/sealed-secrets.crt")
    key = file("${path.module}/bootstrap/sealed-secrets/certificate/sealed-secrets.key")
  }
}

module "proxmox_csi_plugin" {
  depends_on = [module.talos]
  source = "./bootstrap/proxmox-csi-plugin"

  providers = {
    proxmox    = proxmox
    kubernetes = kubernetes
  }

  proxmox = var.proxmox
}
/* 
module "volumes" {
  depends_on = [module.proxmox_csi_plugin]
  source = "./bootstrap/volumes"

  providers = {
    restapi    = restapi
    kubernetes = kubernetes
  }
  proxmox_api = var.proxmox
  volumes = {
    pv-sonarr = {
      node = "pve"
      size = "4G"
    }
    pv-radarr = {
      node = "pve"
      size = "4G"
    }
    pv-lidarr = {
      node = "pve"
      size = "4G"
    }
    pv-prowlarr = {
      node = "prox"
      size = "1G"
    }
    pv-torrent = {
      node = "prox"
      size = "1G"
    }
    pv-remark42 = {
      node = "prox"
      size = "1G"
    }
    pv-authelia-postgres = {
      node = "prox"
      size = "2G"
    }
    pv-lldap-postgres = {
      node = "prox"
      size = "2G"
    }
    pv-keycloak-postgres = {
      node = "prox"
      size = "2G"
    }
    pv-jellyfin = {
      node = "prox"
      size = "12G"
    }
    pv-netbird-signal = {
      node = "mox"
      size = "512M"
    }
    pv-netbird-management = {
      node = "mox"
      size = "512M"
    }
    pv-plex = {
      node = "mox"
      size = "12G"
    }
    pv-prometheus = {
      node = "mox"
      size = "10G"
    }
  }
}
 */