set :rails_env,   "staging"
set :deploy_env,  'staging'

set :domain,      'app.com'
set :deploy_to,   "/home/#{user}/apps/staging.#{domain}"

role :app, domain
role :web, domain
role :db,  domain, primary: true
