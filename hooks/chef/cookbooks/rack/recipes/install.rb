include_recipe 'nginx::default'
include_recipe 'nodejs::default'

execute 'rvm rvmrc warning ignore all.rvmrcs' do
  action :run
end

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

include_recipe 'rack::deploy'
include_recipe 'unicorn::default'