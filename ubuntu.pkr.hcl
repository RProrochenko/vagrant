packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.1.5"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = ">= 1.1.7"
    }
  }
}

source "virtualbox-iso" "ubuntu" {
  vm_name       = "ubuntu-26.04-rpr-base"
  guest_os_type = "Ubuntu_64"

  iso_url      = "https://releases.ubuntu.com/26.04.1/ubuntu-26.04.1-live-server-amd64.iso"
  iso_checksum = "file:https://releases.ubuntu.com/26.04/SHA256SUMS"

  cpus      = 1
  memory    = 8192
  disk_size = 30000

  headless = false

  http_directory = "http"

  ssh_username = "user"
  ssh_password = "1"
  ssh_timeout  = "30m"

  boot_wait = "5s"

  boot_command = [
    "<esc><wait>",
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  shutdown_command = "echo '1' | sudo -S shutdown -P now"
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      "echo 'user ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/user",
      "sudo chmod 440 /etc/sudoers.d/user",
      "sudo apt-get update",
      "sudo apt-get install -y curl git vim htop net-tools ca-certificates",
      "sudo apt-get clean"
    ]
  }

  post-processor "vagrant" {
    output = "builds/ubuntu-26.04-rpr-virtualbox.box"
  }
}
