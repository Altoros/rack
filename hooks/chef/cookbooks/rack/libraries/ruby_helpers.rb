module RubyHelpers
  def run(command)
    %x{ #{command} 2>&1 }
  end

  def wrap_bundle(command)
    "unset BUNDLE_GEMFILE RUBYOPT GEM_HOME && \
    export RAILS_ENV=#{config_get('rack_env')} RACK_ENV=#{config_get('rack_env')} && \
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
