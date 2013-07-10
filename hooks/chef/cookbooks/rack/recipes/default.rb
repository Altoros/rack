package 'git-core' do
  action :install
end

user 'deploy' do
  action :create
  shell '/bin/bash'
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

