set :rails_env,   "staging"
set :deploy_env,  'staging'

set :domain,      'app.com'
set :repository,  "git@repo"

set :deploy_to,   "/home/#{user}/apps/staging.#{domain}"
set :branch,      "develop"

role :app, domain
role :web, domain
role :db,  domain, primary: true
