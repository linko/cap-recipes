set :rails_env,   "production"
set :deploy_env,  'production'

set :application, "app"
set :domain,      'app.com'
set :repository,  "git@repo"

set :deploy_to,   "/home/#{user}/apps/#{application}"
set :branch,      "master"

role :app, domain
role :web, domain
role :db,  domain, primary: true
