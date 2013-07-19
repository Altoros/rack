define :bundle, action: :install do
  node[:rack][:gems_dependencies].each do |bundled_gem, packages|
    if %x(grep -q #{bundled_gem} #{params[:name]}/Gemfile) && $?.success?
      packages.each do |pckg|
        package pckg do
          action :install
        end
      end
    end
  end

  execute 'bundle install' do
    cwd params[:name]
    user 'deploy'
    group 'deploy'
    command wrap_bundle("bundle install --path #{node[:rack][:root]}/shared/bundle")
    action :run
  end
end