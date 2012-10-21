web:  bundle exec unicorn -E production -c /home/deployer/apps/r12-team-33/current/config/unicorn.rb
new_users_worker: bundle exec rake resque:work INTERVAL=60 QUEUES=new_users_processing,existing_users_processing RAILS_ENV=production
existing_users_worker: bundle exec rake resque:work INTERVAL=60 QUEUES=existing_users_processing,new_users_processing RAILS_ENV=production
