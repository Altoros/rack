postgresql = {
  host: juju_relation['host'],
  database: juju_relation['database'],
  username: juju_relation['user'],
  password: juju_relation['password'],
  port: juju_relation['port']
}

if %i(host database username password).any? { |attr| postgresql[attr].nil? || postgresql[attr].empty? }
  puts "Waiting for all attributes being set."
else
  template "#{node[:rack][:root]}/shared/config/database.yml" do
    cookbook 'rack'
    owner 'deploy'
    group 'deploy'
    action :create
    variables({
      rack_env: node[:juju][:rack_env],
      adapter: 'postgresql',
      database: postgresql[:database],
      host: postgresql[:host],
      username: postgresql[:username],
      password: postgresql[:password],
      port: postgresql[:port]
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