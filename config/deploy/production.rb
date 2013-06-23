set :rails_env,   "production"
set :deploy_env,  'production'

set :domain,      'app.com'
set :deploy_to,   -> { "/home/#{user}/apps/#{domain}" }

