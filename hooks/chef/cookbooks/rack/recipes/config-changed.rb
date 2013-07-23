if node.default[:juju][:revision] != node.override[:juju][:revision]
  include_recipe 'rack::deploy'

  service 'rack' do
    ignore_failure true
    provider Chef::Provider::Service::Upstart
    action :restart
  end
end