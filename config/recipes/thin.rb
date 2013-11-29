namespace :thin do

  desc 'Add thin to autoload'
  task :install do
    run "#{sudo} /usr/sbin/update-rc.d -f thin defaults"
  end
  after 'deploy:install', 'thin:install'

  desc 'Setup Thin initializer and app configuration'
  task :setup do
    run "#{sudo} thin config -C #{deploy_to}/shared/config/thin_#{application}.yml -c #{deploy_to}/current  --servers 3 -e production"
    run "#{sudo} ln -nfs #{deploy_to}/shared/config/thin_#{application}.yml /etc/thin/#{application}.yml"

    #template "nginx_#{rails_server}.erb", "/tmp/nginx_conf"
    #run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-available/#{application}.#{domain}"
    #run "#{sudo} ln -nfs /etc/nginx/sites-available/#{application}.#{domain} /etc/nginx/sites-enabled/#{application}.#{domain}"
  end
  after 'deploy:setup', 'thin:setup'
end

#namespace :deploy do
#  task :start, :roles => [:web, :app] do
#    run "cd #{deploy_to}/current && nohup thin -C thin/#{}_config.yml -R config.ru start"
#  end
#
#  task :stop, :roles => [:web, :app] do
#    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R config.ru stop"
#  end
#
#  task :restart, :roles => [:web, :app] do
#    deploy.stop
#    deploy.start
#  end
#
#  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
#  task :cold do
#    deploy.update
#    deploy.start
#  end
#end


