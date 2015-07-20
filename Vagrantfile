# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

cur_dir = File.dirname(File.expand_path(__FILE__))
config_values = YAML.load_file("#{cur_dir}/vagrantfiles/config.yaml")
data = config_values['vagrantfile']

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.

    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://atlas.hashicorp.com/search.
    config.vm.box = "#{data['vm']['box']}"

    config.vm.provider 'virtualbox' do |v|
        v.customize ['modifyvm', :id, '--cpus', "#{data['vm']['cpus']}"]
        v.customize ['modifyvm', :id, '--memory', "#{data['vm']['memory']}"]
        # https://github.com/npm/npm/issues/7308#issuecomment-84214837
        v.customize ['setextradata', :id, 'VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant', '1']
    end

    config.vm.network 'private_network', ip: data['vm']['network']['private_network']

    data['vm']['network']['forwarded_port'].each do |i, port|
        if port['guest'] != '' && port['host'] != ''
            config.vm.network :forwarded_port, guest: port['guest'].to_i, host: port['host'].to_i
        end
    end

    if !data['synced_folder_guest'].nil?
        config.vm.synced_folder "#{cur_dir}", "#{data['synced_folder_guest']}"
    end

    # We currently only provision using shell scripts.
    # If you want to provision using puppet, you need to install puppet itself !
    # https://wiki.debian.org/Teams/Cloud/VagrantBaseBoxes#Provisioners

    config.vm.provision :shell, :path => 'vagrantfiles/shell/apt-update.sh'
    config.vm.provision :shell, :path => 'vagrantfiles/shell/install-rvm.sh', :args => 'stable'
    config.vm.provision :shell, :path => 'vagrantfiles/shell/install-ruby.sh', :args => "#{data['ruby_version']} bundler"
    config.vm.provision :shell, :path => 'vagrantfiles/shell/install-nodejs.sh'

    # startup scripts
    config.vm.provision :shell, run: 'once' do |s|
        s.path = 'vagrantfiles/shell/once.sh'
        s.args = ["#{data['synced_folder_guest']}"]
    end

    config.vm.provision :shell, run: 'always' do |s|
        s.path = 'vagrantfiles/shell/startup.sh'
        s.args = ["#{data['synced_folder_guest']}"]
    end
end
