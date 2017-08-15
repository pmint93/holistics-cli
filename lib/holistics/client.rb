require 'faraday'
require 'uri'

module Holistics
  class Client

    DEFAULT_ENDPOINT = 'https://api.holistics.io'.freeze

    def initialize(endpoint, token)
      @conn = Faraday.new(:url => (endpoint || DEFAULT_ENDPOINT)) do |faraday|
        faraday.request :url_encoded             # form-encode POST params
        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
      @token = token
    end

    def get(path, options = {})
      options[:params] ||= {}
      options[:headers] ||= {}
      response = @conn.get do |req|
        req.url path
        req.headers.merge(options[:headers])
        req.params = options[:params].merge({ '_utoken': @token })
      end
      [response.status, response.body]
    end

    def post(path, options = {})
      options[:params] ||= {}
      options[:headers] ||= {}
      options[:headers].merge!('Content-Type': 'application/json')
      response = @conn.post do |req|
        req.url path
        req.headers.merge!(options[:headers])
        req.params['_utoken'] = @token
        req.body = options[:params].to_s
      end
      [response.status, response.body]
    end

    def delete(path, options = {})
      options[:params] ||= {}
      options[:headers] ||= {}
      options[:headers].merge!('Content-Type': 'application/json')
      response = @conn.delete do |req|
        req.url path
        req.headers.merge!(options[:headers])
        req.body = options[:params].merge({ '_utoken': @token }).to_s
      end
      [response.status, response.body]
    end
  end
end