# Grab the name of the default interface
$default_network_interface = `ip route | awk '/^default/ {printf "%s", $5; exit 0}'`

Vagrant.configure("2") do |mysql|

  mysql.vm.box = "hashicorp/precise64"

  mysql.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  mysql.vm.define "db-server" do |db|
    db.vm.network "public_network", ip: "192.168.0.17", bridge: "#$default_network_interface"
    db.vm.network "forwarded_port", guest: 3306, host: 3306
    db.vm.network "forwarded_port", guest: 80, host: 8306
    db.vm.provision "shell", path: "bootstrap.sh"
  end
end