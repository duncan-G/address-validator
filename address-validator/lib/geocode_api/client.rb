require 'faraday'
require 'json'

module Geocode

    # Strange Bug. Some requests are rejected with error
    #       SSL_connect SYSCALL returned=5 errno=0 state=SSLv2/v3 read server hello A
    # Attempt 5 times as a work around
    class Client
        $ATTEMPS = 5

        def validate_address(address_string)
            result = nil
            i = 0
            while i < $ATTEMPS do
                begin
                    result = Request.where('geocode/json', 'address': address_string)
                    if !result.nil?
                        return result
                    end
                rescue Faraday::SSLError => ex
                    puts "An error of type #{ex.class} happened, message is #{ex.message}"
                rescue Exception => ex 
                    # Don't retry other exceptions
                    # log this and return error
                    return { "status"=> "APP_ERROR", "message"=> ex.message }
                end
                i += 1
            end
            
            # Return error if all 5 tries failed
            { "status"=> "APP_ERROR", "message"=> "Faraday::SSLError" }
        end
    end

    class Connection
        BASE = "https://maps.googleapis.com/maps/api/"
    
        def self.api
            Faraday.new(url: BASE) do |faraday|
                faraday.response :logger
                faraday.adapter Faraday.default_adapter
                faraday.headers['Content-Type'] = 'application/json'
            end
        end
    end
    
    class Request
        @@api_fail_codes = ["OVER_DAILY_LIMIT","OVER_QUERY_LIMIT","REQUEST_DENIED",
            "INVALID_REQUEST","UNKNOWN_ERROR"]

        class << self
            def where(resource_path, query = {}, options = {})
                response, status = get_json(resource_path, query)
                status == 200 ? success(response) : errors(response)
            end
    
            def success(response)
                if @@api_fail_codes.include? response["status"]
                    # Log errors
                    response["status"] = "APP_ERROR"
                end
                response
            end

            def errors(response)
                response["status"] = "APP_ERROR"
                response
            end
    
            def get_json(root_path, query = {})
                query[:key] = ENV['GEOCODE_KEY']
                query_string = query.map{|k,v| "#{k}=#{v}"}.join("&")
                path = query.empty? ? root_path : "#{root_path}?#{query_string}"
                response = api.get(path)
                [JSON.parse(response.body), response.status]
            end
    
            def api
                Connection.api
            end
        end
    end
end


