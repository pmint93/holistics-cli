module Holistics
  module Model
    class JobDefinition < Resource
      def execute(id)
        status, body = @client.post("/#{@name}/#{id}/execute.json")
        handle_http_result(status, body)
      end
    end
  end
end
