namespace :decompose do

  desc 'build docker-compose services'
  task :build do
    on roles(:app) do
      within release_path do
        docker_execute :build
      end
    end
  end

  desc 'shutdown all project services with docker-compose'
  task :down do
    on roles(:app) do
      within release_path do
        docker_execute :down
      end
    end
  end

  desc 'boot up all docker-compose services'
  task :up do
    on roles(:app) do
      within release_path do
        docker_execute :up, '-d'
      end
    end
  end

  desc 'restart services of docker-compose and if not services listed restart all services'
  task :restart do
    on roles(:app) do
      within release_path do
        services = Array(fetch(:decompose_restart))
        if services.empty?
          docker_execute :down
          docker_execute :up
        else
          docker_execute :stop, *services
          docker_execute :up, '-d', *services
        end
      end
    end
  end

  desc 'delete docker images that are not related to current build'
  task :clean do
    on roles(:app) do
      within release_path do
        images_to_delete = capture('docker images -f "dangling=true" -q')
        execute 'docker rmi -f $(docker images -f "dangling=true" -q)' unless images_to_delete.empty?
      end
    end
  end

  desc 'execute a set of rake tasts inside the web container'
  task :rake_tasks do
    on roles(:app) do
      within release_path do
        docker_rake(*fetch(:decompose_rake_tasks)) if fetch(:decompose_rake_tasks)
      end
    end
  end

  desc 'run an interactive command inside the web container'
  task :run do
    on roles(:app) do |host|
      command = ARGV[2..-1].join(' ')
      docker_execute_interactively host, command
    end
  end

  namespace :load do
    desc 'set our variables if they are not yet'
    task :defaults do
      set :decompose_restart, fetch(:decompose_restart, nil)
      set :decompose_web_service, fetch(:decompose_web_service, 'web')
      set :decompose_rake_tasks, fetch(:decompose_rake_tasks, nil)
      set :decompose_compose_file, fetch(:decompose_compose_file, 'docker-compose.yml')
    end
  end

  def docker_rake(*args)		
    docker_execute('run', '--rm', fetch(:decompose_web_service), 'rake', *args)		
  end

  def docker_execute(*args)
    execute('docker-compose', "--project-name #{fetch :application} -f #{fetch :decompose_compose_file}", *args)
  end

  def docker_execute_interactively(host, command)
    user = host.user
    port = fetch(:port) || 22
    docker_run = "docker-compose --project-name #{fetch :application}  -f #{fetch :decompose_compose_file} run --rm #{fetch :decompose_web_service} #{command}"
    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{docker_run}'"
  end

  before 'decompose:build', 'decompose:load:defaults'
  before 'decompose:run', 'decompose:load:defaults'

  after 'deploy:updated', 'decompose:build'
  after 'deploy:published', 'decompose:rake_tasks'
  after 'deploy:published', 'decompose:restart'
  after 'deploy:cleanup', 'decompose:clean'
end
