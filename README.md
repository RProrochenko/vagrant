# Ubuntu 26.04.1 LTS

**Autoinstall + Packer + Vagrant + VirtualBox**

Automated Ubuntu Server deployment using Packer, Ubuntu Autoinstall, Vagrant and VirtualBox.

## Requirements

- Oracle VirtualBox
- HashiCorp Packer
- HashiCorp Vagrant

## Automatic deployment

Run PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\deploy.ps1
```

## What `deploy.ps1` does

1. Packer downloads the Ubuntu 26.04.1 Server ISO.
2. Ubuntu is installed automatically using Autoinstall.
3. Packer creates a Vagrant box file in the `builds` directory.
4. The box is added to Vagrant.
5. Vagrant creates and starts the VirtualBox VM.

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
vagrant box add --name <box-name> .\builds\<box-file>.box
```

If the box already exists and needs to be replaced:

```powershell
vagrant box add --force --name <box-name> .\builds\<box-file>.box
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

## Vagrant box management

List installed boxes:

```powershell
vagrant box list
```

Remove cached box:

```powershell
vagrant box remove <box-name>
```
