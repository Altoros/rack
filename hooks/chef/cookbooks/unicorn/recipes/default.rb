gem_package 'unicorn' do
	action :install
end

directory '/etc/unicorn/' do
	owner 'root'
	group 'root'
	action :create
end

template '/etc/init.d/unicorn' do
	source 'unicorn'
	mode '0755'
	owner 'root'
	group 'root'
end

template '/etc/unicorn/rack.rb' do
	source 'environment.rb'
	owner 'root'
	group 'root'
end

template '/etc/nginx/sites-available/rack' do
	source 'unicorn.conf'
	owner 'root'
 	group 'root'
end

nginx_site 'rack' do
	action :enable
end

nginx_site 'default' do
	action :disable
end

service 'unicorn' do
	action :start
end

service 'nginx' do
	action :restart
end

execute 'open-port 80' do
	action :run
end