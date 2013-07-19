require 'yaml'

module JujuHelpers
  def config_get(key)
    run("config-get #{key}")
  end

  def open_port(port)
    run("open-port #{port}")
  end

  def relation_get(key)
    run("relation-get #{key}")
  end

  def relation_set(params = {})
    params_string = params.map { |key, value| "#{key}=#{value}" }.join(' ')
    run("relation-set #{params_string}")
  end

  def unit_get(key)
    run("unit-get #{key}")
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
    else
      {}
    end
  end

  def immutable_mash_to_hash(mash)
    {}.tap do |hash|
      mash.each do |key, value|
        if value.kind_of?(Chef::Node::ImmutableMash)
          hash[key] = immutable_mash_to_hash(value.to_hash)
        elsif value.kind_of?(Chef::Node::ImmutableArray)
          hash[key] = value.dup
        else
          hash[key] = value
        end
      end
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