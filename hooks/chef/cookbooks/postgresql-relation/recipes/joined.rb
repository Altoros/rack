require 'securerandom'

node.override[:juju][:extra_gems] = %w(pg)

relation_set(database: "rack_#{SecureRandom.hex}")

gemfile "#{node[:rack][:root]}/current/Gemfile" do
  bundled_gem 'pg'
  action :bundle
end