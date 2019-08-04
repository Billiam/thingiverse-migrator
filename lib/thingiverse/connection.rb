require 'http'

module Thingiverse
  class Connection
    THROTTLE_COUNT = 550
    THROTTLE_WINDOW = 300

    def initialize(access_token)
      @access_token = access_token
      @request_stack = []
    end

    def request
      HTTP.auth("Bearer #{@access_token}")
    end

    def throttle
      now = Time.now

      @request_stack.reject! { |time| now - time > THROTTLE_WINDOW }

      if @request_stack.count >= THROTTLE_COUNT
        oldest_request = @request_stack.first
        seconds = THROTTLE_WINDOW - (time - oldest_request)
        puts "Throttling request for #{seconds} seconds"
        sleep seconds
      end

      result = yield

      @request_stack.push(now)

      result
    end

    def fetch(url)
      response = throttle { request.get(url) }

      if response.status == 200
        JSON.parse(response.body)
      end
    rescue SocketError, HTTP::ConnectionError => e
      puts "Request error, retrying"
      retry
    end

    def fetch_paginated(url)
      Enumerator.new do |yielder|
        page = 1

        loop do
          result = fetch("#{url}?page=#{page}")

          if result && result.any?
            result.map do |item|
              yielder << item
            end
            page += 1
          else
            raise StopIteration
          end

        end
      end.lazy
    end
  end
end
