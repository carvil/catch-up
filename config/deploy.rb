require "bundler/capistrano"

server "xxx.xxx.xxx.xxx", :web, :app, :db, primary: true

set :application, "catch-up"
set :github_user, "xxx"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:#{github_user}/#{application}.git"
set :branch, "master"

set :default_environment, {
  'PATH' => "/usr/local/rbenv/shims/:/usr/local/rbenv/bin/:$PATH"
}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup"

namespace :deploy do

  # Use upstart to manage the processes (will need foreman to export the scripts)
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      sudo "#{command} #{application}"
    end
  end

  desc "export upstart scripts with foreman"
  task "foreman_export", roles: :app do
    sudo "mkdir -p /var/log/#{application}"
    sudo "chown #{user} /var/log/#{application}"
    run "cd /home/#{user}/apps/#{application}/current && foreman export upstart /home/#{user}/apps/#{application}/shared/config -a #{application} -u #{user}"
    sudo "mv /home/#{user}/apps/#{application}/shared/config/#{application}* /etc/init/"
  end
  after "deploy:create_symlink", "deploy:foreman_export"

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/twitter.example.yml"), "#{shared_path}/config/twitter.yml"
    put File.read("config/diffbot.example.yml"), "#{shared_path}/config/diffbot.yml"
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/twitter.yml #{release_path}/config/twitter.yml"
    run "ln -nfs #{shared_path}/config/diffbot.yml #{release_path}/config/diffbot.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

end

