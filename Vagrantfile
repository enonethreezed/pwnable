Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_version = "202510.26.0"
  if ENV["PWNABLE_DISABLE_VAGRANT"] == "1"
    config.vm.synced_folder ".", "/vagrant", disabled: true
  end

  (1..11).each do |number|
    config.vm.define "node#{number}" do |node|
      node.vm.hostname = "pwnable#{number}"
      node.vm.network "private_network", ip: "192.168.56.#{10 + number}"
      node.vm.provision "shell", path: "scripts/provision_node.sh", args: [number.to_s]

      node.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = 1024
      end
    end
  end
end
