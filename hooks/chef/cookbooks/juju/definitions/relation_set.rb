define :relation_set do
  args_string = hash_to_shell_args(params[:variables]).join(' ')

  execute "relation-set #{args_string}" do
    action :run
  end
end