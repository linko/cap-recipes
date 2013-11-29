require 'securerandom'

namespace :wordpress do

  task :install do
    puts 'install..'
  end

  task :setup do
    # TODO - create user
    download
    unzip
    #db.mysql.create_database
    template 'wp-config.erb', "#{deploy_to}/wp-config.php"
    setup_nginx
    protect
  end

  task :download do
    run 'wget http://wordpress.org/latest.zip -nd -P /tmp'
  end

  task :unzip do
    run "mkdir -p #{deploy_to}"
    run 'unzip -o -a /tmp/latest.zip -d /tmp/'
    run "cp -fru /tmp/wordpress/*  #{deploy_to}"
  end

  desc 'Protect system files'
  task :protect, :except => { :no_release => true } do
    run "chmod 440 #{deploy_to}/wp-config.php*"
  end

  task :setup_nginx, roles: :web do
    template 'nginx_wordpress.erb', '/tmp/nginx_php_conf'
    run "#{sudo} mv /tmp/nginx_php_conf /etc/nginx/sites-available/#{application}.#{domain}"
    run "#{sudo} ln -nfs /etc/nginx/sites-available/#{application}.#{domain} /etc/nginx/sites-enabled/#{application}.#{domain}"
    nginx.restart
  end



end

