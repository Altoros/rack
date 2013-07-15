module JujuHelpers
  def config_get(name)
    if ENV['JUJU_ENV'] == 'development'
      value = {
        repo: 'https://github.com/pavelpachkovskij/sample-rails',
        scm_provider: 'git',
        rack_env: 'production'
      }[name.to_sym]
    else
      value = %x(config-get #{name}).strip
      value.empty? ? nil : value
    end
  end

  # def config_set(attributes = {})
  #   run("config-set #{attributes.map { |key, value| "#{key}=#{value}" }.join(' ')}")
  # end

  def open_port(port)
    %x(open-port #{port})
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