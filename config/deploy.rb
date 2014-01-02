require 'bundler/capistrano'

set :application, 'cruisecontrol.rb'
set :repository,  'git@github.com:uswitch/cruisecontrol.rb.git'
set :user,        'deploy'

set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{application}"

set :scm_verbose, true
set :keep_releases, 5
set :scm, :git

set :use_sudo, false
set :ssh_options, {:port => 8008, :forward_agent => true}

role :web, 'ec2-54-216-70-68.eu-west-1.compute.amazonaws.com'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  

  task :install_bundler do
    sudo 'gem install bundler'
  end
  
  task :restart do
    sudo 'stop cruisecontrol || echo 0'
    sudo 'start cruisecontrol || echo 0'

    sudo 'stop cruisecontrol_builder || echo 0'
    sudo 'start cruisecontrol_builder || echo 0'
  end
  
  task :restart_nginx do
    sudo '/etc/init.d/nginx restart'
  end
  
  task :install_upstart do
    sudo "cp #{current_path}/config/cruisecontrol.conf /etc/init/cruisecontrol.conf || echo 0"
    sudo "cp #{current_path}/config/cruisecontrol_builder.conf /etc/init/cruisecontrol_builder.conf || echo 0"
  end
   
  after 'deploy:setup', 'deploy:install_bundler'
  after 'deploy:create_symlink', 'deploy:install_upstart'
  afert 'deploy', 'deploy:cleanup'
end