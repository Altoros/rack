module RubyHelpers
  def run(command)
    value = %x{ #{command} 2>&1 }.strip
    value.empty? ? nil : value
  end

  def wrap_bundle(command)
    "unset BUNDLE_GEMFILE RUBYOPT GEM_HOME && \
    export RAILS_ENV=#{node[:juju][:rack_env]} RACK_ENV=#{node[:juju][:rack_env]} && \
    #{command}"
  end
end

class Chef
  class Resource
    include RubyHelpers
  end

  class Recipe
    include RubyHelpers
  end
end
