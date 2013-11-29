# The installation adds a mongodb.conf to /etc/mongodb.conf.
# Use this file to further configure the MongoDB server. After you finish configuring MongoDB,
# you can either use Capistrano to restart the MongoDB server with `cap mongodb:restart`
# or on the server through SSH with `service mongodb restart`.

set_default(:mongodb_password) { Capistrano::CLI.password_prompt 'MongoDB Password: ' }

namespace :mongodb do
  #after "deploy:install", "mongodb:install"
  desc 'Install the latest stable release of Redis.'
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} add-apt-repository 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen'", :pty => true do |ch, stream, data|
      if data =~ /Press.\[ENTER\].to.continue/
        #prompt, and then send the response to the remote process
        ch.send_data(Capistrano::CLI.password_prompt('Press [ENTER] to continue') + "\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end
    end
    run "#{sudo} apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install mongodb-10gen"
  end

  after 'deploy:setup', 'mongodb:setup'
  desc 'Generate the mongoid.yml configuration file.'
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template 'mongoid.yml.erb', "#{shared_path}/config/mongoid.yml"
  end

  after 'deploy:finalize_update', 'mongodb:symlink'
  desc 'Symlink the mongoid.yml file into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
  end

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} MongoDB server."
    task command do
      run "#{sudo} service mongodb #{command}"
    end
  end
end
