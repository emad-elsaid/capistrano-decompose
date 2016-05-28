# Capistrano::Decompose

Add tasks for capistrano to deploy with docker-compose.

## How it works

after capistrano pull your repo and link it to the `current` directory, decompose will invoke `docker-compose build` to build your images and then run some rake tasks that you configured in your deployment with the key `decompose_rake_tasks`, you can add your rails tasks like `db:migration`, `assets:precompile`...etc here, then it will invoke `docker-compose up` or restart only the web service you specified in key `decompose_restart`, also you can use `cap <env> decompose:run` to run any command inside a service, so anytime you need to invoke `rails console` inside you docker image on your server you can use `cap production decompose:run rails console`.

at the end decompose will delete the older images from remote server to keep the server clean.

## Installation

add this line to your Gemfile

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

you can specify the following options in you `deploy.rb` script or the environment specific deploy file:

``` ruby
decompose_restart: an array of services that should be restarted each deployment, if not specified decompose will restart all services
decompose_web_service: the web service that will be used to execute commands inside like `rake` or any interactive command from `decompose:run`, default value: :web
decompose_rake_tasks: a set of rake tasks to execute after each deploy, default value is `nil`
```

for a typical rails application the previous options should be as follows, given that the application container service name is `web`:

```ruby
set :decompose_restart, [:web]
set :decompose_web_service, :web
set :docker_rake_tasks, ['db:migrate', 'assets:precompile']
```

## after the first deployment of a rails application

you would need to setup your database by invoking the `db:setup` task to create and seed your database, you can do that using 2 ways

* `cap production decompose:db_setup`
* `cap production decompose:run rake db:setup`

## General note

* this gem doesn't provide a `dockerfile` or `docker-compose.yml` file, you have to create these files yourself
* the linked directories and files will not work and you should use docker data volumes anyway
