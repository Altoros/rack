if node.default[:juju][:revision] != node.override[:juju][:revision]
  include_recipe 'rack::deploy'

  service 'unicorn' do
    action :restart
  end
end