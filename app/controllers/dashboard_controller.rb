class DashboardController < ApplicationController
  def explain
    @example_project = Project.first
  end
end
