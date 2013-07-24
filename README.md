## Overview

Rack [Juju Charm](http://jujucharms.com/).

## Usage

### Rails 3 example

1. Configure your application, for example html2haml

    **sample-rails.yml**

        sample-rails:
          repo: https://github.com/pavelpachkovskij/sample-rails

2. Deploy Rack application (see configuration section below)

        juju deploy rack sample-rails --config sample-rails.yml

3. Deploy and relate database

        juju deploy postgresql
        juju add-relation postgresql rack

4. Open the stack up to the outside world.

        juju expose rack

5. Find the Rack instance's public URL from

        juju status

#### MySQL setup

On a step 3 run

    juju deploy mysql
    juju add-relation mysql:db rack

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

## Scaling example

```shell
juju deploy rack html2haml --config html2haml.yml
juju deploy haproxy
juju add-unit html2haml -n 2
juju add-relation haproxy html2haml
juju expose haproxy
```

## Source code updates

```shell
juju set <service_name> revision=<revision>
```

## Executing commands

```shell
juju ssh <machine_id> run rake db:migrate
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