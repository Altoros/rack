include_recipe 'rack::deploy'

service 'unicorn' do
  action :restart
end