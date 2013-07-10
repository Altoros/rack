module JujuHelpers
  def config_get(name)
    %x(config-get #{name}).strip
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