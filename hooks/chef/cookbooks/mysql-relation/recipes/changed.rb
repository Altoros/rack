mysql = {
  host: relation_get(:host),
  database: relation_get(:database),
  username: relation_get(:user),
  password: relation_get(:password),
  port: relation_get(:port)
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

  service 'unicorn' do
    restart_command 'service unicorn upgrade'
    ignore_failure true
    action :restart
  end
end

node.override[:juju][:mysql] = mysql