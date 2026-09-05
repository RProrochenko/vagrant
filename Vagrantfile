require "json"

def read_json(path, label)
  config = JSON.parse(File.read(path))
  abort "#{label}: expected a non-empty JSON mapping" unless config.is_a?(Hash) && !config.empty?
  config
rescue JSON::ParserError, SystemCallError => error
  abort "#{label}: #{error.message}"
end

machine_paths = Dir.glob(File.join(__dir__, "config", "machines", "*.json")).sort
abort "config/machines: no VM configuration files found" if machine_paths.empty?

resolved = {}
hostnames = []

machine_paths.each do |path|
  label = "config/machines/#{File.basename(path)}"
  settings = read_json(path, label)
  unknown = settings.keys - %w[os name hostname cpus memory autostart primary synced_folder ssh box build provision]
  abort "#{label}: unknown settings: #{unknown.join(', ')}" unless unknown.empty?

  os_name = settings["os"]
  unless os_name.is_a?(String) && os_name.match?(/\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z/)
    abort "#{label}: os must be a valid OS-template name"
  end
  os_label = "config/os/#{os_name}.json"
  os_config = read_json(File.join(__dir__, "config", "os", "#{os_name}.json"), os_label)
  unknown = os_config.keys - %w[profile build]
  abort "#{os_label}: unknown settings: #{unknown.join(', ')}" unless unknown.empty?

  name = settings["name"]
  unless name.is_a?(String) && name.match?(/\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z/)
    abort "#{label}: name must contain only letters, digits, hyphens and underscores"
  end
  abort "Duplicate machine name: #{name}" if resolved.key?(name)

  profile = os_config["profile"]
  abort "#{os_label}: profile must be a non-empty mapping" unless profile.is_a?(Hash) && !profile.empty?
  unknown = profile.keys - %w[guest communicator winrm resources]
  abort "#{os_label}: unknown profile settings: #{unknown.join(', ')}" unless unknown.empty?

  box = settings["box"]
  abort "#{label}: box must be a non-empty mapping" unless box.is_a?(Hash) && !box.empty?
  unknown = box.keys - %w[name resources]
  abort "#{name}: unknown box settings: #{unknown.join(', ')}" unless unknown.empty?
  abort "#{name}: box must specify name" unless box["name"].is_a?(String) && !box["name"].strip.empty?

  hostname = settings.fetch("hostname", name)
  unless hostname.is_a?(String) && hostname.match?(/\A[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\z/)
    abort "#{name}: hostname must be 1-63 letters, digits or internal hyphens"
  end
  abort "Duplicate hostname: #{hostname}" if hostnames.include?(hostname.downcase)
  hostnames << hostname.downcase

  box_resources = box.fetch("resources", {})
  profile_resources = profile.fetch("resources", {})
  [box_resources, profile_resources].each do |resources|
    unless resources.is_a?(Hash) && (resources.keys - %w[cpus memory]).empty?
      abort "#{name}: resources may contain only cpus and memory"
    end
  end
  options = { "cpus" => 2, "memory" => 2048, "autostart" => false,
              "primary" => false, "synced_folder" => true }
            .merge(box_resources).merge(profile_resources).merge(settings.slice("cpus", "memory", "autostart", "primary", "synced_folder"))
  %w[cpus memory].each do |key|
    abort "#{name}: #{key} must be a positive integer" unless options[key].is_a?(Integer) && options[key].positive?
  end
  %w[autostart primary synced_folder].each do |key|
    abort "#{name}: #{key} must be true or false" unless [true, false].include?(options[key])
  end

  communicator = profile.fetch("communicator", "ssh")
  abort "#{name}: communicator must be ssh or winrm" unless %w[ssh winrm].include?(communicator)
  ssh = settings.fetch("ssh", {})
  if communicator == "ssh"
    abort "#{name}: ssh must be a non-empty mapping" unless ssh.is_a?(Hash) && !ssh.empty?
    allowed = %w[username private_key_path public_key_path insert_key]
    abort "#{name}: unsupported ssh settings" unless (ssh.keys - allowed).empty?
    abort "#{name}: ssh.username must be a non-empty string" unless ssh["username"].is_a?(String) && !ssh["username"].strip.empty?
    %w[private_key_path public_key_path].each do |key|
      abort "#{name}: ssh.#{key} must be a non-empty string" unless ssh[key].is_a?(String) && !ssh[key].strip.empty?
    end
    if ssh.key?("insert_key") && ![true, false].include?(ssh["insert_key"])
      abort "#{name}: ssh.insert_key must be true or false"
    end
  elsif settings.key?("ssh")
    abort "#{name}: ssh settings conflict with #{communicator} communicator"
  end
  if profile.key?("winrm")
    abort "#{name}: winrm must be a mapping" unless profile["winrm"].is_a?(Hash)
    abort "#{name}: winrm settings conflict with #{communicator}" unless communicator == "winrm"
  end
  if profile["guest"] == "windows" && hostname.length > 15
    abort "#{name}: Windows hostname must be at most 15 characters"
  end

  vagrant_profile = profile.merge("box" => box["name"], "ssh" => ssh)
  resolved[name] = [vagrant_profile, options, hostname, communicator]
end

abort "Only one machine may be primary" if resolved.values.count { |_, options, _, _| options["primary"] } > 1

Vagrant.configure("2") do |config|
  resolved.each do |name, (profile, options, hostname, communicator)|
    config.vm.define name, primary: options["primary"], autostart: options["autostart"] do |vm|
      vm.vm.box = profile["box"]
      vm.vm.box_version = profile["box_version"] if profile.key?("box_version")
      vm.vm.hostname = hostname
      vm.vm.guest = profile["guest"].to_sym if profile.key?("guest")
      vm.vm.communicator = communicator
      vm.vm.synced_folder ".", "/vagrant", disabled: true unless options["synced_folder"]

      if communicator == "ssh"
        ssh = profile.fetch("ssh", {})
        vm.ssh.username = ssh["username"] if ssh.key?("username")
        vm.ssh.insert_key = ssh["insert_key"] if ssh.key?("insert_key")
        vm.ssh.private_key_path = File.expand_path(ssh["private_key_path"], __dir__) if ssh.key?("private_key_path")
      elsif profile.fetch("winrm", {}).key?("username")
        vm.winrm.username = profile["winrm"]["username"]
      end

      vm.vm.provider "virtualbox" do |vb|
        vb.memory = options["memory"]
        vb.cpus = options["cpus"]
      end
    end
  end
end
