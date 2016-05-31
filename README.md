# Capistrano::Decompose

[![Gem Version](https://badge.fury.io/rb/capistrano-decompose.svg)](https://badge.fury.io/rb/capistrano-decompose)

Add tasks for capistrano to deploy with docker-compose.

## How it works

After capistrano pull your repo and link it to the `current` directory, decompose will invoke `docker-compose build` to build your images and then run some rake tasks that you configured in your deployment with the key `decompose_rake_tasks`, you can add your rails tasks like `db:migration`, `assets:precompile`...etc here, then it will invoke `docker-compose up` or restart only the web service you specified in key `decompose_restart`, also you can use `cap <env> decompose:run` to run any command inside a service, so anytime you need to invoke `rails console` inside you docker image on your server you can use `cap production decompose:run rails console`.

At the end decompose will delete the older images from remote server to keep the server clean.

## Installation

Add this line to your Gemfile

``` ruby
gem 'capistrano-decompose'
```

And then execute:

``` bash
$ bundle
```

Or install it yourself as:

``` bash
$ gem install capistrano-decompose
```

## Usage

Add this line to your `Capfile`:

``` ruby
require 'capistrano/decompose
```

## Options for deployment

You can specify the following options in you `deploy.rb` script or the environment specific deploy file:

* **decompose_restart**: An array of services that should be restarted each deployment, if not specified decompose will restart all services
* **decompose_web_service**: The web service that will be used to execute commands inside like `rake` or any interactive command from `decompose:run`, default value: :web
* **decompose_rake_tasks**: A set of rake tasks to execute after each deploy, default value is `nil`

For a typical rails application the previous options should be as follows, given that the application container service name is `web`:

```ruby
set :decompose_restart, [:web]
set :decompose_web_service, :web
set :docker_rake_tasks, ['db:migrate', 'assets:precompile']
```

## Defined Tasks

```
decompose:build                # build docker-compose services
decompose:clean                # delete docker images that are not related to current build
decompose:down                 # shutdown all project services with docker-compose
decompose:rake_tasks           # execute a set of rake tasts inside the web container
decompose:restart              # restart services of docker-compose and if not services listed restart all services
decompose:run                  # run an interactive command inside the web container
decompose:up                   # boot up all docker-compose services
```

## After the first deployment of a rails application

You would need to setup your database by invoking the `db:setup` task to create and seed your database:

* `cap production decompose:run rake db:setup`

## General note

* This gem doesn't provide a `dockerfile` nor `docker-compose.yml` file, you have to create these files yourself
* The linked directories and files will not work and you should use docker data volumes anyway
