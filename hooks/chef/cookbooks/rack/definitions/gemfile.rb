define :gemfile, bundled_gem: nil do
  if params[:bundled_gem] && params[:action] == :add
    execute "echo \"\ngem '#{params[:bundled_gem]}'\n\" >> #{params[:name]}" do
      only_if { run("grep -q #{params[:bundled_gem]} #{params[:name]}") }
    end
  end
end