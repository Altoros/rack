require 'securerandom'

node.override[:rack][:extra_gems] = %w(pg unicorn)

relation_set(database: "rack_#{SecureRandom.hex}")

gemfile "#{node[:rack][:root]}/current/Gemfile" do
  bundled_gem 'pg'
  action :bundle
end