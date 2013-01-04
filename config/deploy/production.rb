set :rails_env,   "production"
set :deploy_env,  'production'

set :domain,      'app.com'
set :repository,  "git@repo"

set :deploy_to,   "/home/#{user}/apps/#{domain}"
set :branch,      "master"

role :app, domain
role :web, domain
role :db,  domain, primary: true
