set :rails_env,   "staging"
set :deploy_env,  'staging'

set :branch,      'master'
set :deploy_to,   -> { "/home/#{user}/apps/staging.#{domain}" }