require 'securerandom'

node.override[:juju][:extra_gems] = %w(mysql2)

relation_set(database: "rack_#{SecureRandom.hex}")

gemfile "#{node[:rack][:root]}/current/Gemfile" do
  bundled_gem 'mysql2'
  action :bundle
end