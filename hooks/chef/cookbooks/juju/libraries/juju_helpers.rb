require 'yaml'

module JujuHelpers
  def config_get(name)
    value = %x(config-get #{name}).strip
    value.empty? ? nil : value
  end

  def open_port(port)
    %x(open-port #{port})
  end

  def juju_config
    if ENV['JUJU_ENV'] == 'development'
      {
        repo: 'https://github.com/pavelpachkovskij/sample-rails/trunk',
        scm_provider: 'svn',
        rack_env: 'development',
        revision: '15',
        branch: 'trunk'
      }
    else
      {
        repo: config_get('repo'),
        branch: config_get('branch'),
        revision: config_get('revision'),
        scm_provider: config_get('scm_provider'),
        deploy_key: config_get('deploy_key'),
        svn_username: config_get('svn_username'),
        svn_password: config_get('svn_password'),
        rack_env: config_get('rack_env'),
        extra_packages: config_get('extra_packages'),
        command: config_get('command'),
        port: config_get('port'),
      }
    end
  end

  def read_stored_juju_config
    if File.exists?("#{node[:rack][:root]}/shared/config/juju.yml")
      YAML.load(File.read("#{node[:rack][:root]}/shared/config/juju.yml"))
    end
  end
end

class Chef
  class Resource
    include JujuHelpers
  end

  class Recipe
    include JujuHelpers
  end
end