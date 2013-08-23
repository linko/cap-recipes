namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install, roles: :web do
    run "#{sudo} add-apt-repository ppa:nginx/stable",:pty => true do |ch, stream, data|
      if data =~ /Press.\[ENTER\].to.continue/
        #prompt, and then send the response to the remote process
        ch.send_data(Capistrano::CLI.password_prompt("Press enter to continue:") + "\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end
    end
    run "#{sudo} apt-get -qq update"
    run "#{sudo} apt-get -yq install nginx"
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx_#{rails_server}.erb", "/tmp/nginx_conf"
    run "#{sudo} cp /tmp/nginx_conf /etc/nginx/sites-available/#{stage}.#{domain_name}"
    run "#{sudo} ln -nfs /etc/nginx/sites-available/#{stage}.#{domain_name} /etc/nginx/sites-enabled/#{stage}.#{domain_name}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    run "#{sudo} rm -f /etc/nginx/sites-available/default"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
