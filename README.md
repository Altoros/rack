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

#### Mongodb setup

If you use Mongodb with Mongoid then on a step 3 you should run

    juju deploy mongodb
    juju add-relation mongodb rack


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

## Horizontal scaling of Rack application

Juju makes it easy to scale your Rack application. You can simply deploy any supported load balancer, add relation and launch any number of application instances. Here is HAProxy example:

```shell
juju deploy rack rack --config rack.yml
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

## Configuration

List of available options:

    options:
      repo:
        type: string
        default: "https://github.com/pavelpachkovskij/sample-rails.git"
        description: Application repository URL
      branch:
        type: string
        default: master
        description: Application branch name (git only).
      revision:
        type: string
        default: HEAD
        description: "The revision to be checked out. This can be symbolic, like HEAD or it can be a source control management-specific revision identifier. Default value: HEAD."
      scm_provider:
        type: string
        default: git
        description: The name of the source control management provider to be used (git or svn).
      deploy_key:
        type: string
        default: ""
        description: A deploy key is an SSH key that is stored on the server and grants access to a repository (git only).
      svn_username:
        type: string
        default: ""
        description: The password for the user that has access to the Subversion repository (svn only).
      svn_password:
        type: string
        default: ""
        description: The user name for a user that has access to the Subversion repository (svn only).
      rack_env:
        type: string
        default: production
        description: Both RACK_ENV and RAILS_ENV environment variables.
      extra_packages:
        type: string
        default:
        description: Extra packages to install before bundle install