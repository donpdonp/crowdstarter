source 'https://rubygems.org'

local_gemfile = File.dirname(__FILE__) + "/Gemfile.local"
if File.file?(local_gemfile)
  self.instance_eval(Bundler.read_file(local_gemfile))
end

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'omniauth-facebook'
gem 'boomerang', :git => "git://github.com/donpdonp/boomerang.git"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'rspec-rails'
gem 'slim'
gem 'friendly_id'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

group :production do
  # Use unicorn as the web server
  gem 'unicorn'
end

# Deploy with Capistrano
# gem 'capistrano'

group :development do
  # output tools
  gem 'awesome_print'

  # diagramming
  gem "rails-erd"

  # other
  gem "letter_opener" # show email in the browser in dev mode
end

group :development, :test do
  gem 'factory_girl_rails'
end
