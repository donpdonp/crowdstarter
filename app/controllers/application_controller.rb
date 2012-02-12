class ApplicationController < ActionController::Base
  protect_from_forgery

  helper MiniAuth # available in views
  include MiniAuth # available in controllers

  before_filter :auth
end
