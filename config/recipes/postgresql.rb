# -*- encoding : utf-8 -*-
set_default(:postgresql_host, 'localhost')
set_default(:postgresql_user)     { "#{application}_#{stage}" }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt 'PostgreSQL Password: ' }
set_default(:postgresql_database) { "#{application}_#{stage}_db" }

namespace :postgresql do
  desc 'install the latest stable release of PostgreSQL.'
  task :install, roles: :app do
    #unless ['12.04'].include?(lsb_release)
    #  unless we run 12.04 (which has the latest version in the repos)
    #  we need to add the backports archive
    #  run "#{sudo} add-apt-repository -y ppa:pitti/postgresql"
    #end

    run %Q{ #{sudo} echo "deb http://apt.postgresql.org/pub/repos/apt/ squeeze-pgdg main" >> /tmp/pgdg.list }
    run "#{sudo} cp /tmp/pgdg.list /etc/apt/sources.list.d/pgdg.list"

    run 'wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -'
    run "#{sudo} apt-get -qq update"
    run "#{sudo} apt-get -yq install postgresql-9.3 postgresql-contrib-9.3 libpq-dev"
  end
  after 'deploy:install', 'postgresql:install'


  desc 'Create a database for this application'
  task :create_database, roles: :app do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after 'deploy:setup', 'postgresql:create_database'


  desc 'Generate the database.yml config file'
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template 'postgresql.yml.erb', "#{shared_path}/config/database.yml"
  end
  after 'deploy:setup', 'postgresql:setup'


  desc 'Symlink the database.yml file into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after 'deploy:finalize_update', 'postgresql:symlink'
end
