
### Install recipes
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

Copy everything from Gemfile.example to your Gemfile

Run `bundle install`


### Setup instructions

```bash
cap deploy:install
cap bootstrap
cap deploy:setup
cap deploy
```

