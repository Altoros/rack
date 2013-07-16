%w(libpq++-dev libmysql++-dev libsqlite3-dev).each do |pckg|
  package pckg do
    action :install
  end
end

user 'deploy' do
  home '/home/deploy'
  shell '/bin/bash'
  supports manage_home: true
  action :create
end

%w{config log pids cached-copy bundle system db}.each do |dir|
  directory "#{node[:rack][:root]}/shared/#{dir}" do
    owner 'deploy'
    group 'deploy'
    mode '0755'
    recursive true
    action :create
  end
end

template "#{node[:rack][:root]}/shared/config/database.yml" do
  owner 'deploy'
  group 'deploy'
  action :create_if_missing
  variables({
    rack_env: node[:juju][:rack_env],
    adapter: 'sqlite3',
    database: "#{node[:rack][:root]}/shared/db/rack_#{node[:juju][:rack_env]}.sqlite3"
  })
end