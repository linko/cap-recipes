def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

# List of common utils that should be installed.
set_default :general_packages, <<-EOS
  vim tree imagemagick curl git-core htop ufw
EOS

namespace :deploy do
  desc 'Install everything onto the server'
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties"
    run "#{sudo} apt-get -y install nodejs"
    run "#{sudo} apt-get -y install libcurl3-dev"
    run "#{sudo} apt-get -y install imagemagick"


    run "#{sudo} apt-add-repository ppa:blueyed/ppa",:pty => true do |ch, stream, data|
      if data =~ /Press.\[ENTER\].to.continue/
        #prompt, and then send the response to the remote process
        ch.send_data(Capistrano::CLI.password_prompt('Press [ENTER] to continue') + "\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end
    end

    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install #{general_packages}"
  end
end
