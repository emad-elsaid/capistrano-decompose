$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'capistrano/decompose/version'

Gem::Specification.new do |s|
  s.name        = 'capistrano-decompose'
  s.version     = Capistrano::Decompose::VERSION
  s.authors     = ['Emad Elsaid']
  s.email       = ['blazeeboy@gmail.com']
  s.homepage    = 'https://github.com/blazeeboy/capistrano-decompose'
  s.summary     = 'Capistrano plugin to deploy your application inside docker containers using docker compose'
  s.description = 'Capistrano plugin to deploy your application inside docker containers using docker compose'
  s.license     = 'MIT'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = ['lib']

  s.add_dependency 'capistrano', '~> 3.5'
end
