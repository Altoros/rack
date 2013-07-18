define :gemfile, action: :add, bundled_gem: nil do
  if params[:bundled_gem]
    execute "echo \"\ngem '#{params[:bundled_gem]}'\" >> #{params[:name]}" do
      only_if { %x(grep -q #{params[:bundled_gem]} #{params[:name]}) && !$?.success? }
    end

    if params[:action] == :bundle
      execute wrap_bundle("bundle install --path #{node[:rack][:root]}/shared/bundle") do
        cwd "#{node[:rack][:root]}/current"
        user 'deploy'
        group 'deploy'
        action :run
      end
    end
  end
end