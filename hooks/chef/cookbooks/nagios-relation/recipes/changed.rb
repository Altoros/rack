private_address = unit_get('private-address')

relation_set(
  "monitors" => {
    'monitors' => {
      'remote' => {
        'http' => {
          'rack' => {
            'port' => 80,
            'host' => private_address
          }
        }
      }
    }
  }.to_yaml,
  "target-id" => ENV["JUJU_UNIT_NAME"].gsub('/', '_'),
  "target-address" => private_address
)