require 'resque'

module Resque
  module Failure
    class Sentry < Base
      RESQUE_CONTEXT_KEY = :"Delayed-Job"
      ACTIVE_JOB_CONTEXT_KEY = :"Active-Job"
      ACTIVE_JOB_ADAPTER_NAME = "ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper"

      def save
        ::Sentry.with_scope do |scope|
          scope.set_contexts(**generate_contexts)
          scope.set_tags("resque.queue" => queue)

          ::Sentry::Resque.capture_exception(exception, hint: { background: false })
        end
      end

      def generate_contexts
        context = {}

        if payload["class"] == ACTIVE_JOB_ADAPTER_NAME
          active_job_payload = payload["args"].first

          context[ACTIVE_JOB_CONTEXT_KEY] = {
            job_class: active_job_payload["job_class"],
            job_id: active_job_payload["job_id"],
            arguments: active_job_payload["arguments"],
            executions: active_job_payload["executions"],
            exception_executions: active_job_payload["exception_executions"],
            locale: active_job_payload["locale"],
            enqueued_at: active_job_payload["enqueued_at"],
            queue: queue,
            worker: worker.to_s
          }
        else
          context[RESQUE_CONTEXT_KEY] = {
            job_class: payload["class"],
            arguments: payload["args"],
            queue: queue,
            worker: worker.to_s
          }
        end

        context
      end
    end
  end
end

Resque::Failure.backend = Resque::Failure::Sentry
