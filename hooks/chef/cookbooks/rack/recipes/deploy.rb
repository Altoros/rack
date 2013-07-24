if node[:juju][:extra_packages]
  node[:juju][:extra_packages].split(',').map(&:strip).each do |pckg|
    package pckg do
      action :install
    end
  end
end

case node[:juju][:scm_provider]
  when 'git'
    package 'git-core' do
      action :install
    end
  when 'svn'
    package 'subversion' do
      action :install
    end
  else
    raise ArgumentError
end

if node[:juju][:deploy_key]
  directory "/tmp/private_code/.ssh" do
    owner 'deploy'
    group 'deploy'
    recursive true
  end

  cookbook_file "/tmp/private_code/wrap-ssh.sh" do
    source "wrap-ssh.sh"
    owner 'deploy'
    group 'deploy'
    mode 00700
  end

  file '/tmp/private_code/.ssh/id_deploy' do
    content node[:juju][:deploy_key]
    owner 'deploy'
    group 'deploy'
    mode 00400
  end
end

template "/usr/bin/run" do
  source 'bin/run.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables({
    rack_env: node[:juju][:rack_env]
  })
  action :create
end

template "/usr/bin/service_restart" do
  source 'bin/restart.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

deploy_revision node[:rack][:root] do
  repo node[:juju][:repo]
  action :deploy

  user 'deploy'
  group 'deploy'

  symlink_before_migrate({'config/database.yml' => 'config/database.yml',
                          'config/mongoid.yml' => 'config/mongoid.yml'})

  case node[:juju][:scm_provider]
    when 'git'
      branch node[:juju][:branch]
      ssh_wrapper "/tmp/private_code/wrap-ssh.sh"
    when 'svn'
      revision node[:juju][:revision]
      scm_provider Chef::Provider::Subversion
      svn_username node[:juju][:svn_username]
      svn_password node[:juju][:svn_password]
    else
      raise ArgumentError
  end

  before_migrate do
    # workaround for symlink_before_migrate() http://tickets.opscode.com/browse/CHEF-4374
    directory "#{release_path}/config" do
      user 'deploy'
      group 'deploy'
      action :create
    end

    bundle release_path do
      user 'deploy'
      group 'deploy'
      action :install
    end
  end

  before_restart do
    rake_task 'assets:precompile' do
      cwd "#{node[:rack][:root]}/current"
      user 'deploy'
      group 'deploy'
      ignore_failure true
      action :run
    end
  end
end

rack_procfile 'reverse_merge entries in Procfile' do
  procfile "#{node[:rack][:root]}/current/Procfile"
  entries({web: 'bundle exec rackup config.ru -p $PORT'})
  user 'deploy'
  group 'deploy'
  mode '0644'
  action :reverse_merge
end

template "#{node[:rack][:root]}/current/.env" do
  source '.env.erb'
  user 'deploy'
  group 'deploy'
  mode '0644'
  action :create
  variables({
    rack_env: node[:juju][:rack_env],
    port: 8080
  })
end

rack_procfile 'rack Procfile' do
  cwd "#{node[:rack][:root]}/current"
  user 'deploy'
  app 'rack'
  action :export
end