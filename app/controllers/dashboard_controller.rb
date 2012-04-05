class DashboardController < ApplicationController
  def explain
    @example_projects = Tag.find_by_name("frontpage").projects.order(:funding_due)
  end
end
