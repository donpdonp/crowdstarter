source 'https://rubygems.org'

local_gemfile = File.dirname(__FILE__) + "/Gemfile.local"
if File.file?(local_gemfile)
  self.instance_eval(Bundler.read_file(local_gemfile))
end

gem 'rails', '~> 3.2.16'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'omniauth-facebook', '~> 1.4.1'
gem 'bcrypt-ruby', :require => 'bcrypt'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.10.2'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '~> 2.1.4'
gem 'slim', '~> 3.0.3'
gem 'friendly_id'
gem 'workflow'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'paperclip', "~> 4.2.1"
gem 'loofah-activerecord'
gem 'exception_notification'
gem 'oauth2'
gem 'hashie'
gem 'riemann-client'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

group :production do
  # Use unicorn as the web server
  gem 'unicorn'
  gem 'pg'
end

# Deploy with Capistrano
# gem 'capistrano'

group :development do
  gem 'rspec-rails'

  # output tools
  gem 'awesome_print'

  # diagramming
  gem "rails-erd"

  # other
  gem "letter_opener" # show email in the browser in dev mode
  gem "guard-rspec"
  gem "pry-rails"
end

group :test do
  gem 'capybara'
end
