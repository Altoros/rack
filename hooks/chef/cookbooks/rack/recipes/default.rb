node.default[:rack][:repo] = config_get('repo')
node.save

case config_get('scm_provider')
when 'git'
  package 'git-core' do
    action :install
  end
when 'svn'
  package 'subversion' do
    action :install
  end
else
  raise ArgumentError
end

user 'deploy' do
  home '/home/deploy'
  shell '/bin/bash'
  supports manage_home: true
  action :create
end

if config_get('deploy_key')
  directory "/tmp/private_code/.ssh" do
    owner 'deploy'
    group 'deploy'
    recursive true
  end

  cookbook_file "/tmp/private_code/wrap-ssh.sh" do
    source "wrap-ssh.sh"
    owner 'deploy'
    group 'deploy'
    mode 00700
  end

  file '/tmp/private_code/.ssh/id_deploy' do
    content config_get('deploy_key')
    owner 'deploy'
    group 'deploy'
    mode 00400
  end
end

%w{bin config log pids cached-copy bundle system db}.each do |dir|
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
    rack_env: config_get('rack_env'),
    adapter: 'sqlite3',
    database: "#{node[:rack][:root]}/shared/db/rack_#{config_get('rack_env')}.sqlite3"
  })
end

%w(libpq++-dev libmysql++-dev libsqlite3-dev).each do |pckg|
  package pckg do
    action :install
  end
end

include_recipe 'rack::configure_scripts'