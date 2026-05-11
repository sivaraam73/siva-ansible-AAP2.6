NETWORK_IF = "en0: Ethernet"   # adjust if VBoxManage shows a slightly different name

Vagrant.configure("2") do |config|

  config.vm.define "aap" do |aap|
    AAP_HOSTNAME = "aaptest.siva.local"
    AAP_IP = "192.168.50.50"

    aap.vm.box = "almalinux/10"
    aap.vm.disk :disk, size: "60GB", primary: true
    aap.vm.box_version = "10.1.20251125"
    aap.vm.hostname = AAP_HOSTNAME

    # --- AAP Containerized Ports ---
    aap.vm.network "forwarded_port", guest: 80, host: 8000
    aap.vm.network "forwarded_port", guest: 443, host: 9443
    aap.vm.network "forwarded_port", guest: 8443, host: 8443
    aap.vm.network "forwarded_port", guest: 8444, host: 8444
    aap.vm.network "forwarded_port", guest: 8445, host: 8445
    aap.vm.network "forwarded_port", guest: 8446, host: 8446
    aap.vm.network "forwarded_port", guest: 5432, host: 5432
    aap.vm.network "forwarded_port", guest: 27199, host: 27199
    aap.vm.network "forwarded_port", guest: 6379, host: 6379
    aap.vm.network "forwarded_port", guest: 445, host: 9445

    # AAP Master
    (8080..8088).each do |port|
      aap.vm.network "forwarded_port", guest: port, host: port
    end

    aap.vm.network "public_network",
      ip: AAP_IP,
      bridge: NETWORK_IF

    aap.vm.provider "virtualbox" do |vb|
      vb.memory = "16384"
      vb.cpus = 4
    end

    aap.vm.provision "shell",
      path: "install-aap.sh",
      #args: [AAP_HOSTNAME], [AAP_IP]
      args: "#{AAP_HOSTNAME} #{AAP_IP}",
      privileged: false
      
  end
end

Vagrant.configure("2") do |config|

  # Node
  config.vm.define "node1" do |node1|
    NODE1_HOSTNAME = "node1.siva.local"
    NODE1_IP = "192.168.50.51"

    node1.vm.box = "almalinux/9"
    node1.vm.box_version = "9.7.20260502"
    node1.vm.hostname = NODE1_HOSTNAME


    node1.vm.network "public_network",
      ip: NODE1_IP,
      bridge: NETWORK_IF

    node1.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end

    node1.vm.provision "shell",
      path: "install-node.sh",
      #args: [NODE1_HOSTNAME], [NODE1_IP]
      args: "#{NODE1_HOSTNAME} #{NODE1_IP}",
      privileged: false
     
  end
end

Vagrant.configure("2") do |config|

  # Windows CA
  config.vm.define "winca1" do |winca1|
    WINCA1_HOSTNAME = "winca1"
    WINCA1_IP       = "192.168.50.52"
    
    winca1.vm.box = "StefanScherer/windows_2022"
    #winca1.vm.box_version = "2601.0.0"
    winca1.vm.hostname = WINCA1_HOSTNAME

    #winca1.disksize.size = "60GB"

    winca1.vm.network "public_network",
      ip: WINCA1_IP,
      bridge: NETWORK_IF

    winca1.vm.provider "virtualbox" do |vb|
      vb.memory = "8192"
      vb.cpus = 2
    end

    winca1.vm.communicator = "winrm"

    winca1.winrm.username = "vagrant"
    winca1.winrm.password = "vagrant"
    winca1.winrm.transport = :plaintext
    winca1.winrm.basic_auth_only = true

    winca1.vm.provision "shell",
      path: "install-winca1.ps1",
      args: "#{WINCA1_HOSTNAME} #{WINCA1_IP}",
      privileged: true
  end
end