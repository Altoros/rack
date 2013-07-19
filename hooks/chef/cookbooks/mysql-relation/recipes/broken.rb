node.override[:juju][:mysql] = nil

file "#{node[:rack][:root]}/shared/config/database.yml" do
  action :delete
end

service 'unicorn' do
  restart_command 'service unicorn upgrade'
  ignore_failure true
  action :restart
end