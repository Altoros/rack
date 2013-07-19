if node.default[:juju][:revision] != node.override[:juju][:revision]
  include_recipe 'rack::deploy'

  service 'unicorn' do
    restart_command 'service unicorn upgrade'
    ignore_failure true
    action :restart
  end
end