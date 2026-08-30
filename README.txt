Ubuntu 26.04.1 LTS
Autoinstall + Packer + Vagrant + VirtualBox


Requirements

- Oracle VirtualBox
- HashiCorp Packer
- HashiCorp Vagrant


Automatic deployment

Run PowerShell:

Set-ExecutionPolicy -Scope Process Bypass
.\deploy.ps1


What deploy.ps1 does

1. Packer downloads the Ubuntu 26.04.1 Server ISO.
2. Ubuntu is installed automatically using Autoinstall.
3. Packer creates a Vagrant box file in the builds directory.
4. The box is added to Vagrant.
5. Vagrant creates and starts the VirtualBox VM.


Manual Packer build

Initialize Packer plugins:

packer init .

Validate configuration:

packer validate .

Build Ubuntu box:

packer build .


Manual Vagrant setup

Add the generated box:

vagrant box add --name <box-name> .\builds\<box-file>.box

If the box already exists and needs to be replaced:

vagrant box add --force --name <box-name> .\builds\<box-file>.box


Start VM

vagrant up


Connect to VM

vagrant ssh


VM management

Stop VM:

vagrant halt

Restart VM:

vagrant reload

Destroy VM:

vagrant destroy -f

Check VM status:

vagrant status


Vagrant box management

List installed boxes:

vagrant box list

Remove cached box:

vagrant box remove <box-name>


Important

The Ubuntu 26.04 installer may hang during boot with multiple CPUs
on some VirtualBox versions.

If this occurs, configure the Packer build VM with 1 CPU.

The final VM started by Vagrant can use multiple CPUs and more RAM,
for example:

vb.cpus = 4
vb.memory = 8192


Credentials

The username and password are defined in the Autoinstall user-data file.

The Packer SSH credentials must match the credentials created by Autoinstall.