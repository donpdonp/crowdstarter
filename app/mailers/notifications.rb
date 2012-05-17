class Notifications < ActionMailer::Base
  default from: SETTINGS["notices"]["from"],
           bcc: SETTINGS["notices"]["bcc"]

  def contribution_thanks(contrib)
    @user = contrib.user
    @to = @user.email
    @project = contrib.project
    @subject = "Contribution: {@project.name}"
    @contribution = contrib

    mail to: @to, subject: @subject
  end

  def contribution_collected(contrib)
    subject = "Project funded: #{contrib.project.name}"
    @user = contrib.user
    @project = contrib.project
    @contribution = contrib

    mail to: @user.email, subject: subject
  end

  def contribution_cancelled(contrib)
    subject = "Contribution cancelled: #{contrib.project.name}"
    @user = contrib.user
    @project = contrib.project
    @contribution = contrib

    mail to: @user.email, subject: subject
  end

  def project_failed(project)
    subject = "Project closed: #{project.name}"
    @project = project

    mail to: project.user.email, subject: subject
  end

  def project_funded(project)
    subject = "Project funded: #{project.name}"
    @project = project

    mail to: project.user.email, subject: subject
  end
end
