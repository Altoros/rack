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