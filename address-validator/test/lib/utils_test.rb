require 'test_helper'
require 'utils'
require File.dirname(__FILE__) + '/lib_test_helper'

class UtilTest < ActiveSupport::TestCase
    include Utils

    setup do
        @address_form = AddressForm.new({
            street_address: "1820 California Blvd",
            city: "San Luis Obispo",
            state: "CA",
            zip_code: "93401"
        })

        @validated_address = Address.new(LibTestHelper.sample_address)
    end
    
    test "validated address should be valid" do
        assert @validated_address.valid?, "should be valid"
    end

    test "state should be similar" do
        assert state_similar(@address_form.state, @validated_address.state),
            "#{@address_form.state}, #{@validated_address.state} should be similar"
    end

    test "state should not be similar" do
        @address_form.state = "DE"
        assert_not state_similar(@address_form.state, @validated_address.state),
            "#{@address_form.state}, #{@validated_address.state} should not be similar"
    end

    test "city should be similar" do
        similar_cities = [["San Francisco","San Franciso"],
            ["Silver Springs", "SilverSpring"],
            ["Los Angeles","Los Angellas"],
            ["New York","NewYork"],
            ["New York","NewYok"]]

        similar_cities.each do |city|
            @validated_address.city = city[0]
            @address_form.city = city[1]
            assert city_similar(@address_form.city, @validated_address.city),
                "#{@address_form.city}, #{@validated_address.city} should be similar"
        end
    end

    test "city should not be similar" do
        dissimilar_cities = [["San Francisco","Safrdsf"],
            ["Silver Springs", "SSverSPrn"],
            ["Los Angeles","Lasllas"],
            ["New York","New"],
            ["Newark","Newyork"]]

        dissimilar_cities.each do |city|
            @validated_address.city = city[0]
            @address_form.city = city[1]
            assert_not city_similar(@address_form.city, @validated_address.city),
                "#{@address_form.city}, #{@validated_address.city} should not be similar"
        end
    end

    test "street address should be similar" do
        street1 = "1820 levy Ave NE"
        street2 = "1820 levy Ave NE APT 4"
        assert street_similar(street1,street2), "should be similar"
    end

    test "zip should be similar" do
        zip_codes = [["18202-1534","18202",nil],
            ["18302","18302", "1534"], ["19342-2002","19342","2002"]]

        zip_codes.each do |zip_code|
            @address_form.zip_code = zip_code[0]
            @validated_address.zip_5 = zip_code[1]
            @validated_address.zip_4 = zip_code[2]

            zip_5_similar, zip_4_similar = zip_similar(@address_form.zip_code,
                @validated_address, @validated_address.zip_4)
            assert zip_5_similar, "#{@address_form.zip_code},
                #{@validated_address.zip_5} zip_5 should be similar"
            assert zip_4_similar, "#{@address_form.zip_code},
                #{@validated_address.zip_4} zip_4 should be similar"
        end
    end

end