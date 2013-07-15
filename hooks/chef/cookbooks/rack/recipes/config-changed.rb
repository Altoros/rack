command = config_get('command')

unless command.nil? || command.empty?
  if command == 'update'
    include_recipe 'rack::update'
  else
    execute wrap_bundle("bundle exec #{command}") do
      cwd "#{node[:rack][:root]}/current"
      user 'deploy'
      group 'deploy'
      action :run
    end
  end
end
