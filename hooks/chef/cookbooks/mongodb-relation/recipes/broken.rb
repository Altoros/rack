node.override[:juju][:mongodb] = nil

file "#{node[:rack][:root]}/shared/config/mongoid.yml" do
  action :delete
end

service 'rack' do
  ignore_failure true
  provider Chef::Provider::Service::Upstart
  action :restart
end