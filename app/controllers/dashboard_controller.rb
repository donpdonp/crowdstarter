class DashboardController < ApplicationController
  def explain
    @example_projects = projects_tagged("frontpage")
  end

  private
  def projects_tagged(tag)
    Tag.find_by_name(tag).projects.order(:funding_due)
  end
end
