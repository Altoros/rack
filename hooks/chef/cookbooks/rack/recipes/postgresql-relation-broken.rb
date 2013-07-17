node.override[:juju][:postgresql] = nil

# template "#{node[:rack][:root]}/shared/config/database.yml" do
#   owner 'deploy'
#   group 'deploy'
#   action :create
#   variables({
#     rack_env: node[:juju][:rack_env],
#     adapter: 'sqlite3',
#     database: "#{node[:rack][:root]}/shared/db/rack_#{node[:juju][:rack_env]}.sqlite3"
#   })
# end

service 'unicorn' do
  ignore_failure true
  action :restart
end