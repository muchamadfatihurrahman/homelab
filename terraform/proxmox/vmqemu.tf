resource "proxmox_vm_qemu" "ubuntu-noble-cloud" {

  clone = "ubuntu-noble-cloud"
  full_clone = true

  target_node = "srv1"
  vmid = "251"
  name = "omen"
  desc = "" 
  tags = "rke2"
  
  qemu_os= "l26"

  vga {
    type = "serial0"
  }

  serial {
    id = 0
    type = "socket"
  }


  bios = "seabios"
  scsihw = "virtio-scsi-single"
  agent = 1

  disks { 
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size = "100G"
          iothread = true 
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  sockets = 1
  cores = 8
  vcpus = 2
  cpu_type = "host"
  numa     = true

  memory = 4096
  balloon = 4096

  network {
    id     = 0 
    bridge = "vmbr0"
    tag    = 30
    firewall  = false
    model  = "virtio"
  }
 
  vm_state = "running"
  
  cicustom   = "vendor=Pool:snippets/qemu-guest-agent.yaml"
  ciuser = "fatih"
  cipassword = var.vm_password
  nameserver = "10.10.2.2"
  sshkeys = var.PUBLIC_SSH_KEY
  ciupgrade  = true
  ipconfig0 = "ip=10.10.3.226/24,gw=10.10.3.1"

  onboot = true 
  boot     = "order=scsi0"
  hotplug  = "network,disk,cpu,memory,usb"
  automatic_reboot = false
}