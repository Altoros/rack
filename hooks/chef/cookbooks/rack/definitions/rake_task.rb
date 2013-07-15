define :rake_task, action: :run, user: 'ubuntu', group: 'ubuntu', cwd: nil do
  execute "rake #{params[:name]}" do
    command wrap_bundle("cd #{params[:cwd]} &&  bundle exec rake #{params[:name]}")
    user params[:user]
    group params[:group]
    cwd params[:cwd]
    action params[:action]
    only_if { run(wrap_bundle("cd #{params[:cwd]} && bundle exec rake #{params[:name]} --dry-run")) && $?.success? }
  end
end