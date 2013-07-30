mysql = {
  host: juju_relation['host']
  database: juju_relation['database']
  username: juju_relation['user']
  password: juju_relation['password']
  port: juju_relation['port']
}

if %i(host database username password).any? { |attr| mysql[attr].nil? || mysql[attr].empty? }
  puts "Waiting for all attributes being set."
else
  template "#{node[:rack][:root]}/shared/config/database.yml" do
    cookbook 'rack'
    owner 'deploy'
    group 'deploy'
    action :create
    variables({
      rack_env: node[:juju][:rack_env],
      adapter: 'mysql2',
      database: mysql[:database],
      host: mysql[:host],
      username: mysql[:username],
      password: mysql[:password],
      port: mysql[:port]
    })
  end

  executables do
    action :export
  end

  service 'rack' do
    ignore_failure true
    provider Chef::Provider::Service::Upstart
    action :restart
  end
end