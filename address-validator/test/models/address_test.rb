require 'test_helper'
require 'faker'
require 'utils'

class AddressTest < ActiveSupport::TestCase
  include Utils 

  def address
      address_model = {
        house_number: @faker.building_number,
        street_name: @faker.street_name,
        street_type: @faker. street_suffix,
        street_predirection: nil,
        street_postdirection: nil,
        unit_number: nil,
        unit_type: nil,
        city: @faker.city,
        state: @faker.state,
        county: nil,
        zip_5: nil,
        zip_4: nil
      }

    # Faker does not have county data
    address_model[:county] = rand(1..10)%2 == 0 ? 'A county' : nil

    # Assign an apartment/suite 50% of the time
    # Secondary address has format {unit type}{space}{unit number}
    address_model[:unit_type], address_model[:unit_number]=  rand(1..10)%2 == 0 ?
      @faker.secondary_address.split(' ') : [nil,nil]

    # Zipcode has format XXXXX-XXXX or XXXXX
    address_model[:zip_5],address_model[:zip_4] = @faker.zip.split('-')

    return address_model
  end

  setup do
    @faker = Faker::Address
    @address = Address.new(address())
    @blank_address = Address.new
    @address_form = AddressForm.new({
      street_address: "1820 California Blvd",
      city: "San Luis Obispo",
      state: "CA",
      zip_code: "93401"
    })
  end

  test "should save" do
    assert !!@address.save, "#{@address.inspect} should save"
  end

  test "should require house number" do
    @blank_address.validate({})
    assert_includes(@blank_address.errors[:house_number], "can't be blank")  
  end

  test "should require street name" do
    @blank_address.validate({})
    assert_includes(@blank_address.errors[:street_name], "can't be blank")  
  end

  test "should require street type" do
    @blank_address.validate({})
    assert_includes(@blank_address.errors[:street_type], "can't be blank")  
  end

  test "should require city" do
    @blank_address.validate({})
    assert_includes(@blank_address.errors[:city], "can't be blank")  
  end

  test "should require state" do
    @blank_address.validate({})
    assert_includes(@blank_address.errors[:state], "can't be blank")  
  end

  test "should require zip_5" do
    @blank_address.validate({})
    assert_includes(@blank_address.errors[:zip_5], "can't be blank")  
  end


  test "form should remote validate and Address should save" do
    assert @address_form.valid?, "should be valid"
    validation_response = @address_form.remote_validate

    status = validation_response[:response_type]
    assert_equal :valid_response, status, "#{status} should be #{:valid_response}"

    validated_address = validation_response[:validated_address]
    address_model = Address.new(validated_address)
    assert address_model.valid?, "should be valid #{address_model.errors.full_messages}"
    assert !!address_model.save, "should save"
  end

  test "first_or_create should return existing address" do
    validation_response = @address_form.remote_validate
    validated_address = validation_response[:validated_address]

    address_model = Address.new(validated_address)
    address_model.save
    dup_address = Address.where(validated_address).first_or_create(validated_address)   
    assert_equal address_model.id, dup_address.id, "ids should be the same"
  end

end