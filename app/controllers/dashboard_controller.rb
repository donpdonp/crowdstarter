class DashboardController < ApplicationController
  def explain
    @example_projects = projects_tagged("frontpage", 10)
  end

  def jobs
    @jobs = Delayed::Job.order("run_at desc").all
  end

  private
  def projects_tagged(tag, limit)
    Tag.find_by_name(tag).projects.where(:workflow_state => 'fundable').
                                   order(:funding_due).limit(limit)
  end
end
