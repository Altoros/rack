module RubyHelpers
  def rake_task_defined?(task)
    %x(bundle exec rake #{task} --dry-run") && $?.success?
  end

  def run(command)
    %x{ #{command} 2>&1 }
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
