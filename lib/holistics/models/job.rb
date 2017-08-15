module Holistics
  module Model
    class Job < Resource
      def logs(id, params = {})
        status, body = @client.get("/jobs/#{id}/logs.json", { params: params })
        handle_http_result(status, body)
      end
    end
  end
end
