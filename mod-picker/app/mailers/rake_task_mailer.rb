class RakeTaskMailer < ActionMailer::Base
  default to: "admin@mod-picker.com"
  default from: "no-reply@mod-picker.com"

  def deliver_results(task_key, args, results)
    @task_key = task_key
    @args = args
    @results = results

    mail(subject: "Rake Task [#{task_key}] Completed in [#{Rails.env}]")
  end

  def deliver_failure(task_key, results)
    @task_key = task_key
    @args = args
    @results = results

    mail(subject: "Rake Task [#{task_key}] Failed in [#{Rails.env}]")
  end
end
