# frozen_string_literal: true

require 'colorize'

module Helpers
  module TaskHelper
    class << self

      # Shows task name, memory consumption, benchmarks duration, and wraps block in a transaction.
      # Yields to the block to execute the provided task.
      #
      # +with_transaction+ when true, wraps block in a transaction.
      def wrap_task(task, with_transaction: true)
        # Disables validations wired to if: :validation_pruned?
        # TODO: move to run once at beginning. Is there a before hook?
        ENV['PRUNE_VALIDATIONS'] = 'true'

        puts task.name.cyan.underline

        times = Benchmark.measure do
          with_transaction ? ActiveRecord::Base.transaction { yield } : yield
        end

        puts "\n\t      user     system      total         real\t\t(in seconds)"
        puts "\t#{times}".cyan
        puts "\t#{memory_usage} KB of real memory are in use"
      end

      def log_benchmark(with_transaction: true)
        times = Benchmark.measure do
          with_transaction ? ActiveRecord::Base.transaction { yield } : yield
        end

        Rails.logger.debug "\n\t      user     system      total         real\t\t(in seconds)"
        Rails.logger.debug "\t#{times}".cyan
        Rails.logger.debug "\t#{memory_usage} KB of real memory are in use"
      end

      # TODO: look into this to fix memory usage stats (https://dalibornasevic.com/posts/68-processing-large-csv-files-with-ruby)
      # real memory in 1024 byte increments (aka KB)
      def memory_usage
        `ps -o rss -p #{$PID}`.strip.split.last.to_i
      end
    end
  end
end
