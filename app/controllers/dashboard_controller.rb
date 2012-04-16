class DashboardController < ApplicationController
  def explain
    @example_projects = projects_tagged("frontpage").order(:funding_due).limit(10)
  end

  def jobs
    @jobs = Delayed::Job.order("run_at desc").all
  end

  private
  def projects_tagged(tag)
    Tag.find_by_name(tag).projects.where(:workflow_state => 'fundable')
  end
end
