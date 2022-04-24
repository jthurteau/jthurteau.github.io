# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'podvan/tm' if !defined?(Tm) && File.exist?('podvan/tm.rb')
raise 'Unable to build LDE. Vagrant container tools unavailable.' if !defined?(Tm)

##
# this lighter sandbox build can replace Vagrantfile for public distributions
# use it for Ubuntu or Alpine/Podman setups
app_name = 'test'
ms_config = {
  project: app_name,
  manual_provisioners: [ #[name, file, [script, params]]
    ['reconfigure', 're'],
    'logs',
    'list',
    'start',
    'stop',
    'clean',
    ['container', 'dev-cont', [app_name]],
  ],
  auto_provisioners: [
    ['dependencies', 'dep', ['@project_path']],
    ['updates', 'up'],
    ['auto-container', 'dev-cont', [app_name]],
    #['link-static', 'static']
    'start',
  ]
}

Vagrant.configure('2') do |config|

  Tm::init(ms_config)
  config.vm.define "#{Tm::project()}-container" do |container|
    config.vm.box = 'generic/alpine315'
    config.vm.network :forwarded_port, guest: 80, host: 8080
    if Vagrant.has_plugin?("vagrant-vbguest")
      config.vbguest.auto_update = false
    end
    config.vm.synced_folder '.', '/vagrant', owner: 'vagrant', group: 'vagrant'

    config.vm.provider 'virtualbox' do |v|
      Tm::provision(v, config.vm)
    end
  end

end