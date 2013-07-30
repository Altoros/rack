private_address = unit_get('private-address')

relation_set do
  variables(
    port: 80,
    hostname: unit_get('private-address'),
    private_address: unit_get('private-address'),
    all_services: [
      {
        'service_name' => 'rack',
        'service_port' => 80
      }
    ].to_yaml
  )
end