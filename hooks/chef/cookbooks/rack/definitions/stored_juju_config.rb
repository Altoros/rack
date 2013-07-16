define :stored_juju_config, action: :update do
  if params[:action] == :update
    file "#{node[:rack][:root]}/shared/config/juju.yml" do
      content node[:juju].to_hash.to_yaml
      owner 'deploy'
      group 'deploy'
      mode 00600
      action :create
    end
  end
end