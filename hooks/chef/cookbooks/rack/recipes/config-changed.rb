if node.default[:juju][:revision] != node.override[:juju][:revision]
  include_recipe 'rack::deploy'

  service 'unicorn' do
    ignore_failure true
    action :restart
  end
end