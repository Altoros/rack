module JujuHelpers
  def config_get(name)
    if ENV['JUJU_ENV'] == 'development'
      value = {
        repo: 'https://github.com/pavelpachkovskij/sample-rails',
        scm_provider: 'git'
      }[name.to_sym]
    else
      value = %x(config-get #{name}).strip
      value.empty? ? nil : value
    end
  end

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