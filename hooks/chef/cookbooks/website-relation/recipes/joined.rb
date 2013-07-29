private_address = unit_get('private-address')
relation_set(
  'port' => 80,
  'hostname' => private_address,
  'private-address' => private_address,
  'all_services' => [
      {
        'service_name' => 'rack',
        'service_port' => 80
      }
    ].to_yaml
  )