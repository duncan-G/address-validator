require 'test_helper'
require 'faker'

class AddressTest < ActiveSupport::TestCase    
    def address_form
        return AddressForm.new({street_address:Faker::Address.street_address,
                                city: Faker::Address.city,
                                state: Faker::Address.state_abbr,
                                zip_code: Faker::Address.zip_code})
    end

    setup do
        @blank_address_form = AddressForm.new
        @address_form = address_form()
        # Generate 100 fake US addresses
        @address_forms = []
        (1..100).each do |_|
            @address_forms << address_form()
        end
    end

    test "form should require street address" do
        @blank_address_form.validate({})
        assert_includes(@blank_address_form.errors[:street_address], "can't be blank")  
    end

    test "form should require city" do
        @blank_address_form.validate({})
        assert_includes(@blank_address_form.errors[:city], "can't be blank")  
    end

    test "form should require state" do
        @blank_address_form.validate({})
        assert_includes(@blank_address_form.errors[:state], "can't be blank")  
    end

    test "form should require zip code" do
        @blank_address_form.validate({})
        assert_includes(@blank_address_form.errors[:zip_code], "can't be blank")  
    end

    test "form zip code field should be invalid" do
        invalid_zipcodes = ['astring','2343','23','34544-','234-2342',
                            '45453-43','34534-345','34534-34544']
        invalid_zipcodes.each do |invalid_zip|
            @address_form.zip_code = invalid_zip
            @address_form.validate
            assert_includes(@address_form.errors[:zip_code], "is invalid")
        end
    end

    test "form city field should be invalid" do
        invalid_cities = ['abc#$','$antaFe',"San--Francisco","SanFrancisc0","San_Fran"]
        invalid_cities.each do |invalid_city|
            @address_form.city = invalid_city
            @address_form.validate
            assert_includes(@address_form.errors[:city], "is invalid","City: #{invalid_city}")
        end
    end

    test "form city field should be valid" do
        valid_cities = ["Washington, D.C.","Presqu'ile","Niagara-on-the-Lake",
                        "La Cañada Flintridge"]
        valid_cities.each do |valid_city|
            @address_form.city = valid_city
            @address_form.validate
            assert @address_form.errors[:city].empty?,
                "#{@address_form.city} #{@address_form.errors[:city].inspect}"
        end
    end

    test "form should be valid" do
        @address_forms.each do |form|
            assert form.valid?, "#{form.errors.full_messages.inspect}"
        end
    end

    test "street address should be invalid if invalid house number" do
        @blank_address_form.street_address = "abc street"
        @blank_address_form.validate
        assert_includes(@blank_address_form.errors[:street_address],
            "should start with number", "should be invalid")
    end

    test "street address should be invalid if includes invalid char" do
        invalid_address = ["1100 @ 1st st", "12 st%NE", "193 H $t SW"]
        invalid_address.each do |invalid_address|
            @blank_address_form.street_address = invalid_address
            @blank_address_form.validate
            assert @blank_address_form.errors[:street_address][0].include?('contains invalid char(s)'),
                "#{invalid_address} #{@blank_address_form.errors[:street_address].inspect} should be invalid"
        end
    end
end
