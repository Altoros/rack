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

  case node[:juju][:scm_provider]
    when 'git'
      branch node[:juju][:branch]
      revision node[:juju][:revision]
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

    gemfile "#{release_path}/Gemfile" do
      bundled_gem 'unicorn'
      action :add
    end

    if node[:juju][:extra_gems]
      node[:juju][:extra_gems].each do |extra_gem|
        gemfile "#{release_path}/Gemfile" do
          bundled_gem extra_gem
          action :add
        end
      end
    end

    execute 'bundle install' do
      cwd release_path
      user 'deploy'
      group 'deploy'
      command wrap_bundle("bundle install --path #{node[:rack][:root]}/shared/bundle")
      action :run
    end
  end

  before_restart do
    rake_task 'assets:precompile' do
      cwd "#{node[:rack][:root]}/current"
      user 'deploy'
      group 'deploy'
      action :run
    end
  end
end