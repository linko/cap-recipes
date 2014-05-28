require 'erb'

set_default(:db_host, 'localhost')
set_default(:db_user) { application }
set_default(:mysql_root_password) { Capistrano::CLI.password_prompt 'Please, create MySQL Root password:' }
set_default(:db_pass) { Capistrano::CLI.password_prompt '! MySQL database password: ' }
set_default(:db_admin_pass) { Capistrano::CLI.password_prompt '! MySQL root password: ' }
set_default(:db_name) { "#{application}_#{stage}_db"}

#Capistrano::Configuration.instance.load do
  namespace :db do
    namespace :mysql do
      desc 'Install the latest stable release of MySql.'
      task :install, roles: :db, only: {primary: true} do
        #run "echo #{mysql_password}"
        run "#{sudo} apt-get -y update"
        run "#{sudo} apt-get -y install mysql-server" do |channel, stream, data|
          # prompts for mysql root password (when blue screen appears)
          channel.send_data("#{mysql_root_password}\n\r") if data =~ /password/
          #channel.send_data(Capistrano::CLI.password_prompt('Please, enter mysql root password:') + "\n") if data =~ /password/
        end
        run "#{sudo} apt-get -y install mysql-client libmysqlclient-dev"
      end
      after 'deploy:install', 'db:mysql:install'


      desc 'Create a database and user for this application.'
      task :create_database, roles: :db, only: {primary: true} do
        put "create database #{db_name};
    grant all on #{db_name}.* to '#{db_user}'@'#{db_host}' identified by '#{db_pass}';", '/tmp/mysql_create'
        run "mysql -u root -p'#{db_admin_pass}' < /tmp/mysql_create"
        run 'rm /tmp/mysql_create'
      end
      after 'deploy:setup', 'db:mysql:create_database'

      desc <<-EOF
      |DarkRecipes| Performs a compressed database dump. \
      WARNING: This locks your tables for the duration of the mysqldump.
      Don't run it madly!
      EOF
      task :dump, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        run "mysqldump --user=#{db_user} -p --host=#{db_host} #{db_name} | bzip2 -z9 > #{db_remote_file}" do |ch, stream, out|
          ch.send_data "#{db_pass}\n" if out =~ /^Enter password:/
          puts out
        end
      end

      desc '|DarkRecipes| Restores the database from the latest compressed dump'
      task :restore, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        run "bzcat #{db_remote_file} | mysql --user=#{db_user} -p --host=#{db_host} #{db_name}" do |ch, stream, out|
          ch.send_data "#{db_pass}\n" if out =~ /^Enter password:/
          puts out
        end
      end

      desc '|DarkRecipes| Downloads the compressed database dump to this machine'
      task :fetch_dump, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        download db_remote_file, db_local_file, :via => :scp
      end

      #desc '|DarkRecipes| Create MySQL database and user for this environment using prompted values'
      #task :setup, :roles => :db, :only => { :primary => true } do
      #  prepare_for_db_command
      #
      #  sql = <<-SQL
      #  CREATE DATABASE #{db_name};
      #  GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@localhost IDENTIFIED BY '#{db_pass}';
      #  SQL
      #
      #  run "mysql --user=#{db_admin_user} -p --execute=\"#{sql}\"" do |channel, stream, data|
      #    if data =~ /^Enter password:/
      #      pass = Capistrano::CLI.password_prompt "Enter database password for '#{db_admin_user}':"
      #      channel.send_data "#{pass}\n"
      #    end
      #  end
      #end
      #after 'deploy:setup', 'db:mysql:setup'

      # Sets database variables from remote database.yaml
      def prepare_from_yaml
        set(:db_file) { "#{application}-dump.sql.bz2" }
        set(:db_remote_file) { "#{shared_path}/backup/#{db_file}" }
        set(:db_local_file)  { "tmp/#{db_file}" }
        set(:db_user) { db_config[rails_env]['username'] }
        set(:db_pass) { db_config[rails_env]['password'] }
        set(:db_host) { db_config[rails_env]['host'] }
        set(:db_name) { db_config[rails_env]['database'] }
      end

      def db_config
        @db_config ||= fetch_db_config
      end

      def fetch_db_config
        require 'yaml'
        file = capture "cat #{shared_path}/config/database.yml"
        db_config = YAML.load(file)
      end

      desc 'Symlink the database.yml file into latest release'
      task :symlink, roles: :app do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      end
      after 'deploy:finalize_update', 'db:mysql:symlink'
    end

    desc '|DarkRecipes| Create database.yml in shared path with settings for current stage and test env'
    task :create_yaml do
      set(:db_user) { application }
      set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{stage} database password:" }

      db_config = ERB.new <<-EOF
    #{rails_env}: &base
      adapter: mysql2
      encoding: utf8
      username: #{db_user}
      password: #{db_pass}
      database: #{db_name}
  EOF

      put db_config.result, "#{shared_path}/config/database.yml"
    end
  end



  def prepare_for_db_command
    set :db_name, "#{application}_#{stage}"
    set(:db_admin_user) { Capistrano::CLI.ui.ask 'Username with priviledged database access (to create db):' }
    set(:db_user) { application }
    set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{stage} database password:" }
  end

  desc 'Populates the database with seed data'
  task :seed do
    Capistrano::CLI.ui.say 'Populating the database...'
    run "cd #{current_path}; rake RAILS_ENV=#{variables[:rails_env]} db:seed"
  end

  after 'db:mysql:create_database' do
    db.create_yaml if Capistrano::CLI.ui.agree("Create database.yml in app's shared path? [Yn]")
  end
#end
