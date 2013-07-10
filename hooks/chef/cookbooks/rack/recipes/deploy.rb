deploy_revision '/var/www/rack' do
  repo config_get('repo')
  action :deploy
  symlink_before_migrate({})
  user 'deploy'
  group 'deploy'

  before_migrate do
    execute 'bundle install' do
      cwd release_path
      user 'deploy'
      group 'deploy'
      command "unset BUNDLE_GEMFILE RUBYOPT GEM_HOME && bundle install --deployment --path /var/www/rack/shared/bundle"
      action :run
    end
  end
end