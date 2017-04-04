require 'colorize'

module Helpers
  module TaskHelper
    class << self
      # Shows task name, memory consumption, benchmarks duration, and wraps block in a transaction.
      def wrap_task(task, &block)
        # Disables validations wired to if: :validation_pruned?
        # TODO: move to run once at beginning. Is there a before hook?
        ENV['PRUNE_VALIDATIONS'] = 'true'

        puts task.name.cyan.underline

        times = Benchmark.measure do
          ActiveRecord::Base.transaction do
            block.call
          end
        end

        puts "\n\t      user     system      total         real\t\t(in seconds)"
        puts "\t#{times}".cyan
        puts "\t#{memory_usage} KB of real memory are in use"
      end

      # real memory in 1024 byte increments (aka KB)
      def memory_usage
        `ps -o rss -p #{$$}`.strip.split.last.to_i
      end
    end
  end
end
