# Load the rails application
require File.expand_path('../application', __FILE__)

Slim::Engine.set_options :pretty => true

# Initialize the rails application
Crowdstarter::Application.initialize!
