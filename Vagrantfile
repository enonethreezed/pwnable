Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_version = "202510.26.0"
  config.vm.hostname = "pwnable00"

  config.vm.provision "shell", path: "scripts/update_and_harden.sh"
  config.vm.provision "shell", path: "scripts/provision_users.sh"
  config.vm.provision "shell", path: "scripts/setup_challenge.sh"

  if ENV['CTFADMIN'] == 'false'
    config.vm.provision "shell", inline: <<-SHELL
      if id vagrant &>/dev/null; then
        PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)
        echo "vagrant:${PASS}" | chpasswd
      fi
    SHELL
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
    config.vbguest.no_install = true
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = 2048
    vb.customize ["modifyvm", :id, "--vram", "128"]
  end
end
