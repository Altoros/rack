template "#{node[:rack][:root]}/shared/bin/run" do
  source 'bin/run.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables({
    rack_env: config_get('rack_env')
  })
  action :create
end

template "#{node[:rack][:root]}/shared/bin/service_restart" do
  source 'bin/restart.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/etc/profile.d/rack.sh' do
  owner 'root'
  group 'root'
  mode 0644
end