Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-26.04-rpr-virtualbox"
  config.vm.hostname = "ubuntu-vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "ubuntu-vagrant-rpr"
    vb.memory = 8192
    vb.cpus = 4
  end

  config.ssh.username = "user"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = false

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y curl wget git vim htop jq unzip virtualbox-guest-utils
	curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
  SHELL
end
