Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-26.04-rpr-virtualbox"
  config.vm.hostname = "ubuntu-vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "ubuntu-vagrant-rpr"
    vb.memory = 8192
    vb.cpus = 4
  end

  config.ssh.username = "user"
  config.ssh.password = "1"
  config.ssh.insert_key = false

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y curl wget git vim htop jq unzip
  SHELL
end
