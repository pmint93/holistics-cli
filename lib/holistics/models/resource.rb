module Holistics
  module Model
    class Resource
      attr_accessor :name
      attr_accessor :errors

      def initialize(client, name)
        @client = client
        @name = name
      end

      def all(params = {})
        status, body = @client.get("/#{@name}.json", { params: params })
        handle_http_result(status, body)
      end

      def find(id, params = {})
        status, body = @client.get("/#{@name}/#{id}.json", { params: params })
        handle_http_result(status, body)
      end

      def delete(id, params = {})
        status, body = @client.delete("/#{@name}/#{id}.json", { params: params })
        handle_http_result(status, body)
      end

      private

      def handle_http_result(status, body)
        self.errors = nil
        result = JSON.parse(body)
        if status == 200
          result
        else
          self.errors = [result['error']].concat(result['errors'] || []).compact
          STDERR.puts self.errors.join("\n").red
          exit 1
        end
      end
    end
  end
end
