namespace :runner do
  desc "Enqueue rake task"
  task :enqueue_task, [:task_key] => :environment do |_t, args|
    RakeTaskRunner.perform_async(args.task_key, args.extras)
  end

  desc "Enqueue rake task in the future (in seconds from now)"
  task :enqueue_task_in, [:seconds_from_now, :task_key] => :environment do |_t, args|
    RakeTaskRunner.perform_in(args.seconds_from_now.to_i, args.task_key, args.extras)
  end
end
