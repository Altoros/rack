file "#{node[:rack][:root]}/shared/config/database.yml" do
  action :delete
end

service 'rack' do
  ignore_failure true
  provider Chef::Provider::Service::Upstart
  action :restart
end