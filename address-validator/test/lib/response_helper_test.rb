require 'test_helper'
require 'geocode_api/response_helper'
require File.dirname(__FILE__) + '/lib_test_helper'

class AddressTest < ActiveSupport::TestCase

    test "should restructure response" do
        piped_response = ApiUtils.restructer_response(LibTestHelper.sample_response)
        equality = true
        piped_response.each do |k,v|
            assert v == LibTestHelper.sample_piped_response[k], "#{
                k} should be equal \npiped response: #{v} \nsample piped response: #{LibTestHelper.sample_piped_response[k]}"
        end
    end

    test "should return correct address model from response" do
        sample_street_address = LibTestHelper.sample_street_address
        sample_response = LibTestHelper.sample_response
        sample_address = LibTestHelper.sample_address

        address = ApiUtils.response_helper(sample_response, sample_street_address)
        assert_equal sample_address, address, "should be equal"
    end

    test "should return correct unit type" do
        street_addresses = LibTestHelper.sample_street_addresses

        street_addresses.each do |street_address|
            unit_type = ApiUtils.unit_type_helper(street_address[0])
            assert_equal street_address[1], unit_type, "#{
                street_address} should produce unit type #{street_address[1]} but instead got #{unit_type.inspect}"
        end
    end

    test "should omit unit type" do
        sample_units1 = ["STE 12 E","APT. 12 E", "APT 12 E", "STE.12 E", "APT.12 E"]
        sample_units2 = ["STE F5","APT. F5", "APT. F5", "STE.F5", "APT.F5"]

        sample_units1.each do |sample_unit|
            unit= ApiUtils.unit_number_helper(sample_unit)
            assert_equal "12 E",unit, "should be equal"
        end
        sample_units2.each do |sample_unit|
            unit = ApiUtils.unit_number_helper(sample_unit)
            assert_equal "F5",unit, "should be equal"
        end
    end

    test "should return correct street address info" do
        sample_routes = LibTestHelper.sample_routes

        sample_routes.each do |sample_route|
            street_address = sample_route.delete('street_address')
            route = ApiUtils.route_helper(street_address)
            assert_equal sample_route, route, "#{street_address}\nshould be equal"
        end
    end
end