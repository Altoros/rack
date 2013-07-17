postgresql = {
  host: relation_get(:host),
  database: relation_get(:database),
  username: relation_get(:user),
  password: relation_get(:password),
  port: relation_get(:port)
}

%i(host database user password).each do |attr|
  if postgresql[attr].nil? || postgresql[attr].empty?
    puts "Waiting for all attributes being set, missing: #{attr}"
  else
    template "#{node[:rack][:root]}/shared/config/database.yml" do
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

    service 'unicorn' do
      ignore_failure true
      action :restart
    end
  end
end

node.override[:juju][:postgresql] = postgresql