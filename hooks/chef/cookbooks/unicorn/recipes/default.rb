gem_package 'unicorn' do
	action :install
end

template '/etc/init.d/unicorn' do
	source 'unicorn'
	mode '0755'
	owner 'root'
	group 'root'
end

directory '/vagrant/config/unicorn' do
	owner 'vagrant'
	group 'vagrant'
	action :create
end

template '/vagrant/config/unicorn/development.rb' do
	source 'environment.rb'
	owner 'vagrant'
	group 'vagrant'
end

template '/etc/nginx/conf.d/unicorn.conf' do
	source 'unicorn.conf'
	owner 'www-data'
	group 'www-data'
end

%w(pids sockets).each do |dir|
	directory "/vagrant/tmp/#{dir}" do
		owner 'vagrant'
		group 'vagrant'
		action :create
	end
end

service 'unicorn' do
	action [:enable, :start]
end

service 'nginx' do
	action :restart
end