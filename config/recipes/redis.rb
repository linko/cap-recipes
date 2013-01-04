# The installation adds a redis.conf to /etc/redis/redis.conf.
# Use this file to further configure the Redis server. After you finish configuring Redis,
# you can either use Capistrano to restart the Redis server with `cap redis:restart`
# or on the server through SSH with `service redis-server restart`.

namespace :redis do
  after "deploy:install", "redis:install"
  desc "Install the latest stable release of Redis."
  task :install, roles: :db, only: {primary: true} do

    run "#{sudo} add-apt-repository ppa:rwky/redis",:pty => true do |ch, stream, data|
      if data =~ /Press.\[ENTER\].to.continue/
        #prompt, and then send the response to the remote process
        ch.send_data(Capistrano::CLI.password_prompt("Press [ENTER] to continue") + "\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end
    end

    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install redis-server"
  end

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} Redis server."
    task command do
      run "#{sudo} service redis-server #{command}"
    end
  end
end