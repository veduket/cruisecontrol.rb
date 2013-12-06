require 'bundler/capistrano'

set :application, "cruisecontrol.rb"
set :repository,  "git@github.com:uswitch/cruisecontrol.rb.git"
set :user,        "deploy"

set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{application}"

set :scm_verbose, true
set :keep_releases, 5
set :scm, :git

set :use_sudo, false
set :ssh_options, {:port => 8008, :forward_agent => true}

role :web, "ec2-54-228-156-149.eu-west-1.compute.amazonaws.com"


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  

  task :install_bundler do
    sudo "gem install bundler"
  end
  
  task :restart do
    sudo "stop switching-reporting || echo 0"
    sudo "start switching-reporting || echo 0"
  end
  
  task :restart_nginx do
    sudo "/etc/init.d/nginx restart"
  end
  
  task :install_upstart do
    sudo "cp #{current_path}/config/cruisecontrol.conf /etc/init/cruisecontrol.conf || echo 0"
  end
   
  desc "Create symlink to the export folder using by the plan ending report"
  task :symlink_export do
    run "rm -rf #{release_path}/export"
    run "mkdir -p #{shared_path}/export"
    run "ln -nfs #{shared_path}/export #{release_path}/export"
  end
  
  task :sid do
    run "cd #{current_path} && RACK_ENV=production bundle exec rake consumptions_test"
  end

  after "deploy:setup", "deploy:install_bundler"
  after "deploy", "deploy:install_upstart", "deploy:cleanup", "worker:restart", "deploy:install_cron"
  after "deploy:update_code", "deploy:symlink_export"
end