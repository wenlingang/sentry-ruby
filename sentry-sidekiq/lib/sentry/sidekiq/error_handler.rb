require 'sentry/sidekiq/context_filter'
require 'sentry/sidekiq/util'

module Sentry
  module Sidekiq
    class ErrorHandler
      def call(ex, context)
        return unless Sentry.initialized?

        scope = Sentry.get_current_scope
        scope.set_transaction_name(Util.transaction_name_from_context(context)) unless scope.transaction_name

        filtered_context = Sentry::Sidekiq::ContextFilter.new.filter_context(context)

        Sentry::Sidekiq.capture_exception(
          ex,
          extra: { sidekiq: filtered_context },
          hint: { background: false }
        )
      end
    end
  end
end
