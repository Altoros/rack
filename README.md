## Overview

Rack [Juju Charm](http://jujucharms.com/).

## Usage

### Rails 3 example

1. Configure your application, for example:

    **sample-rails.yml**

        sample-rails:
          repo: https://github.com/pavelpachkovskij/sample-rails

2. Deploy Rack application (see configuration section below)

        juju deploy rack sample-rails --config sample-rails.yml

3. Deploy and relate database

        juju deploy postgresql
        juju add-relation postgresql:db sample-rails

4. Run migrations if you need it.

        juju ssh sample-rails/0 run rake db:migrate

    And e.g. database seeds

        juju ssh sample-rails/0 run rake db:seed

5. Open the stack up to the outside world.

        juju expose rack

6. Find the Rack instance's public URL from

        juju status

#### MySQL setup

On a step 3 run

    juju deploy mysql
    juju add-relation mysql rack

### Sinatra example

1. Configure your application, for example html2haml

    **html2haml.yml**

        html2haml:
          repo: https://github.com/twilson63/html2haml.git

2. Deploy your application with Rack Charm

        juju deploy rack html2haml --config html2haml.yml

4. Open the stack up to the outside world.

        juju expose html2haml

## Source code updates

```shell
juju set <service_name> revision=<revision>
```

## Executing commands

```shell
juju ssh <unit_name> run <command>
```

## Restart application

```bash
juju ssh <unit_name> sudo restart rack
```

## Foreman integration

You can add Procfile to your application and Rack charm will use it for deployment.

Example Procfile:

    web: bundle exec unicorn -p $PORT
    watcher: bundle exec rake watch

## Specifying a Ruby Version

You can use the ruby keyword of your app’s Gemfile to specify a particular version of Ruby.

```ruby
source "https://rubygems.org"
ruby "1.9.3"
````

## Logstash setup

You can add logstash service to collect information from application's logs and Kibana application to visualize this data.

```shell
juju deploy kibana
juju deploy logstash-indexer
juju add-relation kibana logstash-indexer:rest

juju deploy logstash-agent
juju add-relation logstash-agent logstash-indexer
juju add-relation logstash-agent rack
juju set logstash-agent CustomLogFile="['/var/www/rack/current/log/*.log']" CustomLogType="rack"
juju expose kibana
```

## Horizontal scaling of Rack application

Juju makes it easy to scale your Rack application. You can simply deploy any supported load balancer, add relation and launch any number of application instances. Here is HAProxy example:

```shell
juju deploy rack rack --config rack.yml
juju deploy haproxy
juju add-relation haproxy rack
juju expose haproxy
juju add-unit rack -n 2
```

### Apache2 as a load balancer

Apache2 is harder to start with, but it provides more flexibility with configuration options.
Here is a quick example of using Apache2 as a load balancer with your rack application:

Deploy Rack application

```shell
juju deploy rack --config rack.yml
```

You have to enable mod_proxy_balancer and mod_proxy_http modules in your Apache2 config:

**apache2.yml** example

```yaml
apache2:
  enable_modules: proxy_balancer proxy_http
```

Deploy Apache2

```shell
juju deploy apache2 --config apache2.yml
```

Create balancer relation between Apache2 and Rack application

```shell
juju add-relation apache2:balancer rack
```

Apache2 charm expects a template to be passed in. Example of vhost that will balance all traffic over your application instances:

**vhost.tmpl**

```xml
<VirtualHost *:80>
  ServerName rack
  ProxyPass / balancer://rack/ lbmethod=byrequests stickysession=BALANCEID
  ProxyPassReverse / balancer://rack/
</VirtualHost>
```

Update Apache2 service config with this template

```shell
juju set apache2 "vhost_http_template=$(base64 < vhost.tmpl)"
```

Expose Apache2 service

```shell
juju expose apache2
```

## Nagios and NRPE relation

You can can perform HTTP checks with Nagios. To do this deploy Nagios and relate it to your Rack application:

```shell
juju deploy nagios
juju add-relation rack nagios
```

Additionally you can run disk, mem, and swap checks with NRPE extension:

```shell
juju deploy nrpe
juju add-relation rack nrpe
juju add-relation nrpe nagios
```

## MongoDB relation

Deploy MonogDB service and relate it to Rack application:

    juju deploy mongodb
    juju add-relation mongodb rack

Rack charm will set environment variables which you can use to configure your Mongodb adapter.

```ruby
MONGODB_URL   => mongodb://host:port/database
```

### Use with Mongoid 2.x

Your mongoid.yml should look like:

```yml
production:
  uri: <%= ENV['MONGODB_URL'] %>
```

### Use with Mongoid 3.x and 4.x

Your mongoid.yml should look like:

```yml
production:
  sessions:
    default:
      uri: <%= ENV['MONGODB_URL'] %>
```

In both cases you can set additional options specified by Mongoid.

## Memcached relation

Deploy Memcached service and relate it to Rack application:

```shell
juju deploy memcached
juju add-relation memcached rack
```

Rack charm will set environment variables which you can use to configure your Memcache adapter. [Dalli](https://github.com/mperham/dalli) use those variables by default.

```ruby
MEMCACHE_PASSWORD    => xxxxxxxxxxxx
MEMCACHE_SERVERS     => instance.hostname.net
MEMCACHE_USERNAME    => xxxxxxxxxxxx
```

## Redis relation

Deploy Redis service and relate it to Rack application:

```bash
juju deploy redis-master
juju add-relation redis-master:redis-master rack
```

Rack charm will set environment variables which you can use to configure your Redis adapter.

```ruby
REDIS_URL   => redis://username:password@my.host:6389
```

For example you can configure Redis adapter in config/initializers/redis.rb

```ruby
uri = URI.parse(ENV["REDIS_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
```

## Known issues

### Rack application didn't start because assets were not compiled

To be able to compile assets before you've joined database relation you have to disable initialize_on_precompile option in application.rb:

```ruby
config.assets.initialize_on_precompile = false
```

If you can't do this you still can join database and compile assets manually:

```bash
juju ssh rack/0 run rake assets:precompile
```

Then restart Rack service (while you have to replace 'rack/0' with your application name, e.g. 'sample-rails/0', 'sudo restart rack' is a valid command to restart any deployed application):

```bash
juju ssh rack/0 sudo restart rack
```

## Configuration

### Deploy from Git

Sample Git config:

```yml
rack:
  repo: <repository_url>
  branch: <branch_name>
```

To deploy from private repo via SSH add 'deploy_key' option:

```yml
deploy_key: <private_key>
```

### Deploy from SVN

Sample SVN config:

```yml
rack:
  scm_provider: svn
  repo: <repository_url>
  revision: <branch_name>
  svn_username: <username>
  svn_password: <password>
```

### Install extra packages

Specify list of packages separated by spaces:

```yml
  extra_packages: 'libsqlite3++-dev libmagick++-dev'
```

### Set ENV variables

You can set ENV variables, which will be available within all processes defined in a Procfile:

```yml
  env: 'AWS_ACCESS_KEY_ID=aws_access_key_id AWS_SECRET_ACCESS_KEY=aws_secret_access_key'
```