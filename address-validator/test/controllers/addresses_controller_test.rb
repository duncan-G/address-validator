require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  test "should get new address" do
    get new_address_path
    assert_response :success
  end
end
