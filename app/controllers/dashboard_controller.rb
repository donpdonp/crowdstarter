class DashboardController < ApplicationController
  def explain
    @example_projects = projects_tagged("frontpage")
  end

  def jobs
    @jobs = Delayed::Job.order("run_at desc").all
  end

  private
  def projects_tagged(tag)
    Tag.find_by_name(tag).projects.where(:workflow_state => 'fundable').
        order(:funding_due)
  end
end
