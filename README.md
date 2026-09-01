# Ubuntu 26.04.1 LTS

**Autoinstall + Packer + Vagrant + VirtualBox**

Ubuntu Server image built with Packer and Autoinstall, then started with Vagrant and VirtualBox.

## Requirements

- Oracle VirtualBox
- HashiCorp Packer
- HashiCorp Vagrant

## Configuration

Vagrant box name:

```text
ubuntu-26.04-rpr-virtualbox
```

Generated box file:

```text
.\builds\ubuntu-26.04-rpr-virtualbox.box
```

Default lab credentials:

```text
Login: user
Password: vagrant
```

> The default password is intended only for an isolated lab environment.

## Build and start

Run the following commands from the project root in PowerShell:

```powershell
New-Item -ItemType Directory -Force .\builds | Out-Null

.\packer.exe init .
.\packer.exe validate .
.\packer.exe build -force .

vagrant box add --force --name ubuntu-26.04-rpr-virtualbox .\builds\ubuntu-26.04-rpr-virtualbox.box
vagrant up --provider virtualbox
```

The commands use the bundled `.\packer.exe`. If Packer is installed in `PATH`,
`packer` can be used instead.

## Connect to VM

```powershell
vagrant ssh
```

## VM management

Stop VM:

```powershell
vagrant halt
```

Restart VM:

```powershell
vagrant reload
```

Destroy VM:

```powershell
vagrant destroy -f
```

Check VM status:

```powershell
vagrant status
```

## Clean rebuild after changing Packer or Autoinstall configuration

Build the new box first. Only after Packer finishes successfully, destroy the old
VM, replace the registered box, and create a new VM:

```powershell
New-Item -ItemType Directory -Force .\builds | Out-Null

.\packer.exe init .
.\packer.exe validate .
.\packer.exe build -force .

vagrant destroy -f
vagrant box add --force --name ubuntu-26.04-rpr-virtualbox .\builds\ubuntu-26.04-rpr-virtualbox.box
vagrant up --provider virtualbox
```

> `vagrant destroy -f` permanently deletes the current project VM. Back up any
> required data before running the clean rebuild.

## Vagrant box management

List installed boxes:

```powershell
vagrant box list
```

Remove cached box:

```powershell
vagrant box remove ubuntu-26.04-rpr-virtualbox
```
