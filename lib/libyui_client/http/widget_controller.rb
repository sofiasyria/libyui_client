# frozen_string_literal: true

module LibyuiClient
  module Http
    class WidgetController
      def initialize(host:, port:)
        @host = host
        @port = port
      end

      # Find a widget using the filter.
      # @param filter [Hash] identifiers to find a widget
      # @param timeout [Numeric] how long to wait (in seconds).
      # @param interval [Numeric] time in seconds between attempts.
      # @return [Response]
      def find(filter, timeout:, interval:)
        res = nil
        Wait.until(timeout: timeout, interval: interval) do
          uri = HttpClient.compose_uri(@host, @port, '/widgets', filter)
          res = HttpClient.http_get(uri)
          Response.new(res) if res.is_a?(Net::HTTPOK)
        end
      rescue Error::TimeoutError
        rescue_errors(res)
      end

      # Perform an action on the widget.
      # @param filter [Hash] identifiers to find a widget
      # @param action [Hash] what to do with the widget
      # @param timeout [Numeric] how long to wait (in seconds).
      # @param interval [Numeric] time in seconds between attempts.
      # @return [Response]
      def send_action(filter, action, timeout:, interval:)
        res = nil
        Wait.until(timeout: timeout, interval: interval) do
          uri = HttpClient.compose_uri(@host, @port, '/widgets',
                                       filter.merge(action))
          res = HttpClient.http_post(uri)
          Response.new(res) if res.code.to_i == 200
        end
      rescue Error::TimeoutError
        rescue_errors(res)
      end

      private

      def rescue_errors(response)
        raise Error::WidgetNotFoundError if response.is_a?(Net::HTTPNotFound)

        raise Error::ItemNotFoundInWidgetError if response.is_a?(Net::HTTPUnprocessableEntity)

        raise Error::LibyuiClientError
      end
    end
  end
end
