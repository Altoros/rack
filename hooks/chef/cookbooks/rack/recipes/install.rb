include_recipe 'nginx::default'
include_recipe 'nodejs::default'
include_recipe 'rack::default'
include_recipe 'rack::deploy'

service 'rack' do
  ignore_failure true
  provider Chef::Provider::Service::Upstart
  action :start
end

service 'nginx' do
  action :start
end

juju_port 80 do
  action :open
end