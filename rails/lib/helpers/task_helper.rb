# frozen_string_literal: true

require 'colorize'

module Helpers
  module TaskHelper
    class << self

      # Shows task name, memory consumption, benchmarks duration, and wraps block in a transaction.
      # Yields to the block to execute the provided task.
      def wrap_task(task)
        # Disables validations wired to if: :validation_pruned?
        # TODO: move to run once at beginning. Is there a before hook?
        ENV['PRUNE_VALIDATIONS'] = 'true'

        puts task.name.cyan.underline

        times = Benchmark.measure do
          ActiveRecord::Base.transaction do
            yield
          end
        end

        puts "\n\t      user     system      total         real\t\t(in seconds)"
        puts "\t#{times}".cyan
        puts "\t#{memory_usage} KB of real memory are in use"
      end

      # real memory in 1024 byte increments (aka KB)
      def memory_usage
        `ps -o rss -p #{$PID}`.strip.split.last.to_i
      end
    end
  end
end
