set :rails_env,   "production"
set :deploy_env,  'production'

set :branch,      'master'
set :deploy_to,   -> { "/home/#{user}/apps/#{domain}" }

