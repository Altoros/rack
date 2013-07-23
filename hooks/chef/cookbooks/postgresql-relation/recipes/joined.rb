require 'securerandom'

relation_set(database: "rack_#{SecureRandom.hex}")
