node.default[:juju] = read_stored_juju_config

if node[:juju].nil?
  node.default[:juju] = juju_config
else
  node.override[:juju] = juju_config
end