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

    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--cpus", "#{data['vm']['cpus']}"]
        v.customize ["modifyvm", :id, "--memory", "#{data['vm']['memory']}"]
    end

    config.vm.network 'private_network', ip: data['vm']['network']['private_network']

    data['vm']['network']['forwarded_port'].each do |i, port|
        if port['guest'] != '' && port['host'] != ''
            config.vm.network :forwarded_port, guest: port['guest'].to_i, host: port['host'].to_i
        end
    end

    if !data['vm']['post_up_message'].nil?
        config.vm.post_up_message = "#{data['vm']['post_up_message']}"
    end

    if !data['synced_folder_guest'].nil?
        config.vm.synced_folder "#{cur_dir}", "#{data['synced_folder_guest']}"
    end

    if !data['vm']['provision']['puppet'].nil?
        # Install puppet to enable provisioning
        # https://wiki.debian.org/Teams/Cloud/VagrantBaseBoxes#Provisioners
        config.vm.provision 'shell', path: 'vagrantfiles/puppet/shell/puppet.sh'

        config.vm.provision :puppet do |puppet|

            puppet.facter = {
                'user'                 => "#{data['user']}",
                'application_name'     => "#{data['application_name']}",
                'ruby_version'         => "#{data['ruby_version']}",
                'server_name'          => "#{data['vm']['hostname']}",
                'port'                 => "#{data['vm']['network']['forwarded_port']['ports']['guest']}"
            }

            puppet.manifests_path = data['vm']['provision']['puppet']['manifests_path']
            puppet.manifest_file = data['vm']['provision']['puppet']['manifest_file']
            puppet.options = ['--templatedir', "#{data['vm']['provision']['puppet']['template_path']}"]
            puppet.options = "#{data['vm']['provision']['puppet']['options']}"
        end
    end

    # startup scripts
    config.vm.provision :shell, run: 'once' do |s|
        s.path = 'vagrantfiles/puppet/shell/once.sh'
        s.args = ['startup-once']
    end

    config.vm.provision :shell, run: 'always' do |s|
        s.path = 'vagrantfiles/puppet/shell/startup.sh'
        s.args = ['startup-always']
    end
end
