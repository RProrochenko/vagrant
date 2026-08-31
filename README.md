# Ubuntu 26.04.1 LTS

**Autoinstall + Packer + Vagrant + VirtualBox**

Automated Ubuntu Server deployment using Packer, Ubuntu Autoinstall, Vagrant and VirtualBox.

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
Password: 1
```

> The default password is intended only for an isolated lab environment.

## Automatic deployment

Run PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\deploy.ps1
```

## What `deploy.ps1` does

1. Checks that Packer, Vagrant and VirtualBox are installed.
2. Checks whether the Vagrant box `ubuntu-26.04-rpr-virtualbox` already exists.
3. If it does not exist, Packer downloads Ubuntu Server 26.04.1 and installs it using Autoinstall.
4. Packer creates `.\builds\ubuntu-26.04-rpr-virtualbox.box`.
5. The box is added to Vagrant.
6. Vagrant creates and starts the VirtualBox VM.

## Manual Packer build

Initialize Packer plugins:

```powershell
packer init .
```

Validate configuration:

```powershell
packer validate .
```

Build Ubuntu box:

```powershell
packer build .
```

## Manual Vagrant setup

Add the generated box:

```powershell
vagrant box add --name ubuntu-26.04-rpr-virtualbox .\builds\ubuntu-26.04-rpr-virtualbox.box
```

If the box already exists and needs to be replaced:

```powershell
vagrant box add --force --name ubuntu-26.04-rpr-virtualbox .\builds\ubuntu-26.04-rpr-virtualbox.box
```

## Start VM

```powershell
vagrant up
```

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

`deploy.ps1` skips the Packer build when the box is already installed locally.
To guarantee that configuration changes are included in a new VM:

```powershell
vagrant destroy -f
vagrant box remove ubuntu-26.04-rpr-virtualbox --force
Remove-Item -Recurse -Force .\builds -ErrorAction SilentlyContinue
.\deploy.ps1
```

## Vagrant box management

List installed boxes:

```powershell
vagrant box list
```

Remove cached box:

```powershell
vagrant box remove ubuntu-26.04-rpr-virtualbox
```
