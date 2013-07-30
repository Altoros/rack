def whyrun_supported?
  true
end

action :merge do
  converge_by("Update #{ @new_resource }") do
    env = dotenv_args

    @new_resource.variables.each do |key, value|
      env[key.to_s.upcase] = shell_quote(value)
    end

    file @new_resource.name do
      content hash_to_shell_args(env).join("\n")
      user new_resource.user
      group new_resource.group
      mode new_resource.mode
      action :create
    end
  end
end

action :delete_variables do
  converge_by("Update #{ @new_resource }") do
    env = dotenv_args

    unless env.blank?
      @new_resource.delete_variables.each do |key|
        env.delete(key.to_s.upcase)
      end

      file @new_resource.name do
        content hash_to_shell_args(env).join("\n")
        user new_resource.user
        group new_resource.group
        mode new_resource.mode
        action :create
      end
    end
  end
end