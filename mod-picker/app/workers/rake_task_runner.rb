require 'benchmark'

class RakeTaskRunner
  include Sidekiq::Worker

  attr_accessor :args, :task_key

  def perform(task_key, *args)
    @task_key = task_key
    @args = args

    output << run_task

    deliver_results
  end

  def error_occurred
    @error_occurred ||= false
  end

  def output
    @output ||= ""
  end

  def run_task
    capture_stdout do
      benchmark_time = Benchmark.measure do
        begin
          Rake::Task[task_key].invoke(*args)
        rescue => exception
          puts "Error occured while running task: #{exception.message}"
          puts "Backtrace: #{exception.backtrace}"
          error_occurred = true
        end
      end

      Rake::Task[task_key].reenable

      puts "\n"
      puts "#{task_key} (time in seconds): #{benchmark_time}"
    end
  end

  def deliver_results
    if error_occurred
      RakeTaskMailer.deliver_failure(task_key, args, output).deliver
    else
      RakeTaskMailer.deliver_results(task_key, args, output).deliver
    end
  end

  def capture_stdout(&block)
    stdout = StringIO.new
    $stdout = stdout
    yield
    stdout.string
  end
end
