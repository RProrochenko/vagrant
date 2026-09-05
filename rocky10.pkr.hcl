variable "rocky10_machine_config_path" {
  type    = string
  default = "config/machines/rocky.json"
}

variable "rocky10_build_cpus" {
  type    = number
  default = null
}

variable "rocky10_build_memory" {
  type    = number
  default = null
}

variable "rocky10_box_output_path" {
  type    = string
  default = null
}

variable "rocky10_build_output_directory" {
  type    = string
  default = null
}

variable "rocky10_headless" {
  type    = bool
  default = true
}

locals {
  rocky10_machine_config   = jsondecode(file("${path.root}/${var.rocky10_machine_config_path}"))
  rocky10_os_config        = jsondecode(file("${path.root}/config/os/rocky10.json"))
  rocky10_build_config     = local.rocky10_machine_config.build
  rocky10_os_build_config  = local.rocky10_os_config.build
  rocky10_box_config       = local.rocky10_machine_config.box
  rocky10_provision_config = local.rocky10_machine_config.provision
  rocky10_ssh_config       = local.rocky10_machine_config.ssh
  rocky10_packages         = try(local.rocky10_provision_config.packages, [])
  rocky10_install_docker   = try(local.rocky10_provision_config.install_docker, false)
  rocky10_build_cpus       = coalesce(var.rocky10_build_cpus, local.rocky10_build_config.resources.cpus)
  rocky10_build_memory     = coalesce(var.rocky10_build_memory, local.rocky10_build_config.resources.memory)
  rocky10_box_output_path  = coalesce(var.rocky10_box_output_path, "${path.root}/builds/${local.rocky10_box_config.name}.box")
  rocky10_output_directory = coalesce(var.rocky10_build_output_directory, "${path.root}/${local.rocky10_build_config.output_directory}")
  rocky10_http_content = {
    "/rocky.ks" = templatefile("${path.root}/http/rocky/rocky.ks.pkrtpl.hcl", {
      hostname       = local.rocky10_machine_config.hostname
      username       = local.rocky10_ssh_config.username
      authorized_key = trimspace(file("${path.root}/${local.rocky10_ssh_config.public_key_path}"))
    })
  }
}

source "virtualbox-iso" "rocky10" {
  vm_name       = local.rocky10_build_config.vm_name
  guest_os_type = local.rocky10_os_build_config.guest_os_type

  iso_url      = local.rocky10_os_build_config.iso_url
  iso_checksum = local.rocky10_os_build_config.iso_checksum

  cpus      = local.rocky10_build_cpus
  memory    = local.rocky10_build_memory
  disk_size = local.rocky10_os_build_config.disk_size

  output_directory = local.rocky10_output_directory
  headless         = var.rocky10_headless

  guest_additions_mode = "disable"
  http_content         = local.rocky10_http_content

  ssh_username         = local.rocky10_ssh_config.username
  ssh_private_key_file = "${path.root}/${local.rocky10_ssh_config.private_key_path}"
  ssh_timeout          = "30m"

  boot_wait = "5s"

  boot_command = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    " inst.k inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky.ks",
    "<f10>"
  ]
  shutdown_command = "sudo shutdown -P now"
}

build {
  sources = ["source.virtualbox-iso.rocky10"]

  provisioner "shell" {
    inline = concat(
      ["sudo dnf -y update"],
      local.rocky10_install_docker ? [
        "curl -fsSL https://get.docker.com -o /tmp/get-docker.sh",
        "sudo sh /tmp/get-docker.sh",
        "rm -f /tmp/get-docker.sh",
        "sudo usermod -aG docker ${local.rocky10_ssh_config.username}"
      ] : [],
      length(local.rocky10_packages) > 0 ? ["sudo dnf -y install ${join(" ", local.rocky10_packages)}"] : [],
      ["sudo dnf clean all"]
    )
  }

  post-processor "vagrant" {
    output = local.rocky10_box_output_path
  }
}
