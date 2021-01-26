module Sentry
  module Sidekiq
    class Util
      SIDEKIQ_NAME = "Sidekiq".freeze

      def self.transaction_name_from_context(context)
        classname = (context["wrapped"] || context["class"] ||
                      (context[:job] && (context[:job]["wrapped"] || context[:job]["class"]))
                    )

        if classname
          "#{SIDEKIQ_NAME}/#{classname}"
        elsif context[:event]
          "#{SIDEKIQ_NAME}/#{context[:event]}"
        else
          SIDEKIQ_NAME
        end
      end
    end
  end
end
