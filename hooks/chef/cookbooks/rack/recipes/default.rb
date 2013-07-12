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
  action :create
  shell '/bin/bash'
  supports manage_home: true
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

%w{config log pids cached-copy bundle system}.each do |dir|
  directory "/var/www/rack/shared/#{dir}" do
    owner 'deploy'
    group 'deploy'
    mode '0755'
    recursive true
    action :create
  end
end

file '/var/www/rack/shared/config/database.yml' do
  owner 'deploy'
  group 'deploy'
  action :create
end

%w(libpq++-dev libmysql++-dev).each do |pckg|
  package pckg do
    action :install
  end
end