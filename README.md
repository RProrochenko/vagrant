# Ubuntu 26.04.1 LTS Vagrant Box

**Autoinstall + Packer + Vagrant + VirtualBox**

Локальний Ubuntu Server dev-box. Packer автоматично встановлює Ubuntu 26.04.1, Docker, Docker Compose, VirtualBox Guest Utilities та базові CLI-утиліти. Доступ до VM налаштовано через SSH key.

## Вимоги

- Oracle VirtualBox
- HashiCorp Packer
- HashiCorp Vagrant

## SSH key

Проєкт містить SSH key pair:

```text
ssh/private-key
ssh/private-key.pub
```

- `private-key` використовують Packer і Vagrant.
- `private-key.pub` додано до `http/user-data` → `ssh.authorized-keys`.
- SSH password authentication вимкнена.

Щоб створити нову пару ключів:

```powershell
ssh-keygen -t ed25519 -f .\ssh\private-key -C "packer-vagrant"
```

Після генерації скопіюй public key:

```powershell
Get-Content .\ssh\private-key.pub
```

і заміни ним значення в `http/user-data`.

> Private key дає доступ до VM, створених із цього box. Репозиторій має бути приватним.

## Build

Виконувати з кореня проєкту:

```powershell
New-Item -ItemType Directory -Force .\builds | Out-Null

.\packer.exe init .
.\packer.exe fmt .
.\packer.exe validate .
.\packer.exe build -force .
```

Готовий box:

```text
.\builds\ubuntu-26.04-rpr-virtualbox.box
```

> `ubuntu.pkr.hcl` зараз використовує шлях `C:/git/vagrant/ssh/private-key`. Якщо проєкт перенесено, онови `ssh_private_key_file`.

## Vagrant

`Vagrantfile` має використовувати SSH key:

```ruby
config.ssh.username = "user"
config.ssh.private_key_path = ["C:/git/vagrant/ssh/private-key"]
config.ssh.insert_key = false
```

Додати box і запустити VM:

```powershell
vagrant box add --force --name ubuntu-26.04-rpr-virtualbox .\builds\ubuntu-26.04-rpr-virtualbox.box
vagrant up --provider virtualbox
```

Docker уже встановлюється під час Packer build, тому Docker-provisioner у `Vagrantfile` не потрібен.

## Шпаргалка

```powershell
vagrant ssh
vagrant status
vagrant halt
vagrant reload
vagrant destroy -f
```

Перевірити компоненти у VM:

```powershell
vagrant ssh -c "docker --version"
vagrant ssh -c "docker compose version"
vagrant ssh -c "id && groups"
```

## Повний rebuild

Після зміни `ubuntu.pkr.hcl` або `http/user-data`:

```powershell
.\packer.exe validate .
.\packer.exe build -force .

vagrant destroy -f
vagrant box add --force --name ubuntu-26.04-rpr-virtualbox .\builds\ubuntu-26.04-rpr-virtualbox.box
vagrant up --provider virtualbox
```

> `vagrant destroy -f` безповоротно видаляє поточну VM.

## Діагностика

```powershell
.\packer.exe validate .
.\packer.exe build -debug .
vagrant global-status
```