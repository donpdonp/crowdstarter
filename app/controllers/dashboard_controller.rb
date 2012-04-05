class DashboardController < ApplicationController
  def explain
    @projects_count = Project.count
    @contributions_amount = Contribution.successful.sum(:amount)
    @example_projects = Tag.find_by_name("frontpage").projects
  end
end
