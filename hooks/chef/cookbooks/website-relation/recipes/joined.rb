hostname = unit_get('private-address')
relation_set(port: 80, hostname: hostname)