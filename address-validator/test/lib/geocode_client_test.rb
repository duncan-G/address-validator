require 'test_helper'
require 'geocode_api/response_helper'
require 'geocode_api/client'
require 'faker'
require File.dirname(__FILE__) + '/lib_test_helper'

class GeocodeApiTest < ActiveSupport::TestCase

    setup do
        @api_client = Geocode::Client.new
        @street_address = []
        (1..5).each do |_|
            @street_address << Faker::Address.full_address
        end
    end

    test "api should return response" do
        @street_address.each do |address|
            result = @api_client.validate_address(address)
            # result success
            assert !!result, "result should not be nil"
            # Non status 200 error
            assert_not result.keys.include?('error'), "should have no errors,#{result}"
            # Error after status code 200 (error from api)
            assert_not result.keys.include?('error_message'), "should have no errors,#{result}"
            # Has results payload or found 0 results matching address
            assert_includes ['OK','ZERO_RESULTS'], result['status'], "should have results payload #{result}"
        end
    end
end