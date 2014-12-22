# Install recipes for quick server setup
This bunch of recipes is aimed to help you with automatical server setup. No handjob required.

## Serverside
Assuming you have root priveligies:
###Add new user
```bash
useradd -m [username] -s /bin/bash
```
###Grant access rights to new user 
Run `visudo` and add:
```
username ALL=(ALL:ALL) NOPASSWD: ALL
```
###Remote repo keys 
Add remote repo keys to users .ssh/known_hosts to avoid requests while running cap procedures
Git:
```bash
cap system_user:copy_ssh_keys
```

## Locally in your app
### Add recipes
```bash
git submodule add git@github.com:linko/cap-recipes.git
cd cap-recipes && git checkout recap
```

### Copy files
```bash
cp cap-recipes/Capfile.recap.example ./
mkdir config/deploy
cp cap-recipes/config/deploy/* ./config/deploy/
```

### Update your .gitignore
Add here
```
config/unicorn.rb
.recap-lock
/cap-recipes
```

### Update Gemfile
Copy everything from Gemfile.example to your Gemfile and run `bundle install`

### Check needed recipes to be included
Verify you'd included correct recipes for your application (i.e. mysql recipe for application on postgres) in `Capfile`. For example:
```ruby
set :recipes_dir, File.expand_path('/cap-recipes', __FILE__)
load recipes_dir + '/config/recipes/base'
load recipes_dir + '/config/recipes/nginx'
load recipes_dir + '/config/recipes/unicorn'
```

### Setup instructions

```bash
bundle exec cap deploy:install
bundle exec cap bootstrap
bundle exec cap deploy:setup
```

### Comment recipes loading
Open Capfile and comment part with recipes loading
```ruby
set :recipes_dir, File.expand_path('/cap-recipes', __FILE__)
load recipes_dir + '/config/recipes/base'
load recipes_dir + '/config/recipes/nginx'
load recipes_dir + '/config/recipes/postgresql'
load recipes_dir + '/config/recipes/rbenv'
load recipes_dir + '/config/recipes/unicorn'
```
### Final deploy

```bash
bundle exec cap deploy
```
