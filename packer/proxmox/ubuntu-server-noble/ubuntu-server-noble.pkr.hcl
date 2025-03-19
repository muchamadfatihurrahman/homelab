variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

source "proxmox-iso" "ubuntu-server-noble" {

    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"

    node = "srv1"
    vm_id = "110"
    vm_name = "ubuntu-server-noble"

    boot_iso {
        iso_file = "Pool:iso/ubuntu-24.04-live-server-amd64.iso"
        unmount = true
    }

    scsi_controller = "virtio-scsi-single"

    qemu_agent = true

    disks {
        disk_size = "32G"
        storage_pool = "local-lvm"
        type = "scsi"
    }

    sockets = "1"
    cores = "4"
    cpu_type = "host" 
    numa = true

    memory = "16384"

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        vlan_tag = "30"
        firewall = true
    }

    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]

    boot                    = "c"
    boot_wait               = "5s"
    communicator            = "ssh"

    http_directory          = "http"
    http_port_min           = 8802
    http_port_max           = 8802

    ssh_username            = "fatih"
    ssh_private_key_file    = "~/.ssh/fatih"
    ssh_timeout             = "120m"
    ssh_pty                 = true
}

build {

    name = "ubuntu-server-noble"
    sources = ["source.proxmox-iso.ubuntu-server-noble"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

}
