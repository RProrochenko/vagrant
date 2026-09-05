variable "ubuntu26_machine_config_path" {
  type    = string
  default = "config/machines/default.json"
}

variable "ubuntu26_build_cpus" {
  type    = number
  default = null
}

variable "ubuntu26_build_memory" {
  type    = number
  default = null
}

variable "ubuntu26_box_output_path" {
  type    = string
  default = null
}

variable "ubuntu26_build_output_directory" {
  type    = string
  default = null
}

variable "ubuntu26_headless" {
  type    = bool
  default = true
}

locals {
  ubuntu26_machine_config   = jsondecode(file("${path.root}/${var.ubuntu26_machine_config_path}"))
  ubuntu26_os_config        = jsondecode(file("${path.root}/config/os/ubuntu26.json"))
  ubuntu26_build_config     = local.ubuntu26_machine_config.build
  ubuntu26_os_build_config  = local.ubuntu26_os_config.build
  ubuntu26_box_config       = local.ubuntu26_machine_config.box
  ubuntu26_provision_config = local.ubuntu26_machine_config.provision
  ubuntu26_ssh_config       = local.ubuntu26_machine_config.ssh
  ubuntu26_packages         = try(local.ubuntu26_provision_config.packages, [])
  ubuntu26_install_docker   = try(local.ubuntu26_provision_config.install_docker, false)
  ubuntu26_build_cpus       = coalesce(var.ubuntu26_build_cpus, local.ubuntu26_build_config.resources.cpus)
  ubuntu26_build_memory     = coalesce(var.ubuntu26_build_memory, local.ubuntu26_build_config.resources.memory)
  ubuntu26_box_output_path  = coalesce(var.ubuntu26_box_output_path, "${path.root}/builds/${local.ubuntu26_box_config.name}.box")
  ubuntu26_output_directory = coalesce(var.ubuntu26_build_output_directory, "${path.root}/${local.ubuntu26_build_config.output_directory}")
  ubuntu26_http_content = {
    "/meta-data" = ""
    "/user-data" = templatefile("${path.root}/http/user-data.pkrtpl.hcl", {
      hostname       = local.ubuntu26_machine_config.hostname
      username       = local.ubuntu26_ssh_config.username
      authorized_key = trimspace(file("${path.root}/${local.ubuntu26_ssh_config.public_key_path}"))
    })
  }
}

source "virtualbox-iso" "ubuntu26" {
  vm_name       = local.ubuntu26_build_config.vm_name
  guest_os_type = local.ubuntu26_os_build_config.guest_os_type

  iso_url      = local.ubuntu26_os_build_config.iso_url
  iso_checksum = local.ubuntu26_os_build_config.iso_checksum

  cpus      = local.ubuntu26_build_cpus
  memory    = local.ubuntu26_build_memory
  disk_size = local.ubuntu26_os_build_config.disk_size

  output_directory = local.ubuntu26_output_directory

  headless             = var.ubuntu26_headless
  guest_additions_mode = "disable"

  http_content = local.ubuntu26_http_content

  ssh_username         = local.ubuntu26_ssh_config.username
  ssh_private_key_file = "${path.root}/${local.ubuntu26_ssh_config.private_key_path}"
  ssh_timeout          = "30m"

  boot_wait = "5s"

  boot_command = [
    "<esc><wait>",
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  shutdown_command = "sudo shutdown -P now"
}

build {
  sources = ["source.virtualbox-iso.ubuntu26"]

  provisioner "shell" {
    inline = concat(
      ["sudo apt-get update"],
      local.ubuntu26_install_docker ? [
        "curl -fsSL https://get.docker.com -o /tmp/get-docker.sh",
        "sudo sh /tmp/get-docker.sh",
        "rm -f /tmp/get-docker.sh",
        "sudo usermod -aG docker ${local.ubuntu26_ssh_config.username}"
      ] : [],
      length(local.ubuntu26_packages) > 0 ? ["sudo apt-get install -y ${join(" ", local.ubuntu26_packages)}"] : [],
      ["sudo apt-get clean"]
    )
  }

  post-processor "vagrant" {
    output = local.ubuntu26_box_output_path
  }
}
