set :rails_env,   'staging'
set :branch,      'staging'
set :deploy_to,   -> { "/home/#{user}/apps/#{stage}.#{domain_name}" }

top.env.current_environment.set 'RAILS_ENV', 'staging'
