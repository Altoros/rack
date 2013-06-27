package 'postgresql' do
	action :install
end

package 'libpq++-dev' do
	action :install
end

execute 'create root role' do
	command 'sudo -u postgres psql -c "CREATE ROLE root WITH PASSWORD \'root\' SUPERUSER LOGIN"'
end