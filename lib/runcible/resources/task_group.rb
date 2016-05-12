module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/dispatch/index.html
    class TaskGroup < Runcible::Base
      # Generates the API path for Tasks
      #
      # @param  [String]  id  the id of the task
      # @return [String]      the task path, may contain the id if passed
      def self.path(id = nil)
        id.nil? ? 'task_groups/' : "task_groups/#{id}/"
      end

      def self.summary_path(id)
        "task_groups/#{id}/state_summary/"
      end

      # summary for the status of a task
      #
      # @param  [String]              id  the id of the task
      # @return [RestClient::Response]
      def summary(id)
        call(:get, self.class.summary_path(id))
      end

      # checks if all tasks in the summary report have completed
      # @param [Hash] the summary report obtained from summary(id) call
      # @return true if tasks in the summary report have completed
      def completed?(summary_report)
        sum = 0
        ["finished", "canceled", "skipped", "suspended", "error"].each do |state|
          sum += summary_report[state] if summary_report[state]
        end
        sum == summary_report["total"]
      end
    end
  end
end
