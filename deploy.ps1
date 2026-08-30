$ErrorActionPreference = "Stop"

$BoxName = "ubuntu-autoinstall-rpr"
$BoxFile = ".\builds\ubuntu-24.04.4-virtualbox.box"

Write-Host "Checking required commands..."

foreach ($cmd in @("packer", "vagrant", "VBoxManage")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "Command '$cmd' not found. Install Packer, Vagrant and VirtualBox first."
    }
}

$BoxExists = vagrant box list | Select-String "^$([regex]::Escape($BoxName))\s"

if (-not $BoxExists) {
    Write-Host "Box not found. Building Ubuntu from ISO..."

    if (-not (Test-Path ".\builds")) {
        New-Item -ItemType Directory -Path ".\builds" | Out-Null
    }

    packer init .
    packer validate .
    packer build .

    if (-not (Test-Path $BoxFile)) {
        throw "Box file was not created: $BoxFile"
    }

    Write-Host "Adding box to Vagrant..."
    vagrant box add --name $BoxName $BoxFile
}
else {
    Write-Host "Vagrant box already exists: $BoxName"
}

Write-Host "Starting VM..."
vagrant up --provider virtualbox

Write-Host ""
Write-Host "Done."
Write-Host "SSH: vagrant ssh"
Write-Host "Login: user"
Write-Host "Password: 1"
