require 'securerandom'

mongodb = {
  host: relation_get(:hostname),
  port: relation_get(:port),
  database: "rack_#{SecureRandom.hex}"
}

if %i(host port).any? { |attr| mongodb[attr].nil? || mongodb[attr].empty? }
  puts "Waiting for all attributes being set."
else
  template "#{node[:rack][:root]}/shared/config/mongoid.yml" do
    owner 'deploy'
    group 'deploy'
    action :create
    variables({
      rack_env: node[:juju][:rack_env],
      database: mongodb[:database],
      host: mongodb[:host],
      port: mongodb[:port]
    })
  end

  service 'rack' do
    ignore_failure true
    provider Chef::Provider::Service::Upstart
    action :restart
  end
end