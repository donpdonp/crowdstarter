class DashboardController < ApplicationController
  def explain
    @example_item = Project.first
  end
end
