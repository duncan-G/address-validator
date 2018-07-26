require 'utils'

class AddressForm
    include ActiveModel::Model
    include Utils

    attr_accessor :street_address, :city, :state, :zip_code
    VALID_ZIP_REGEX = /\A\d{5}(-\d{4})?\z/
    VALID_CITY_REGEX = /\A(?:[a-zA-Z\u0080-\u024F]+(?:[.',-])?\s?)+\z/
    VALID_HOUSE_NUMBER_REGEX = /\A[0-9].+\z/
    VALID_STREET_ADDRESS_REGEX = /\A[a-zA-Z0-9\u0080-\u024F\s,#\.'-]+\z/

    validates :street_address,
              presence: true,
              format: { with: VALID_HOUSE_NUMBER_REGEX, message: "should start with number"}

    validates :street_address,
              format: { with: VALID_STREET_ADDRESS_REGEX, message: -> (model, data) do 
                    "contains invalid char(s): " +
                        data[:value].split('').reject { # Get invalid chars
                            |e| VALID_STREET_ADDRESS_REGEX =~ e }.uniq.join(' ') unless data[:value].nil?
                end
                }

    validates :city, presence: true, format: { with: VALID_CITY_REGEX }
    validates :state, presence: true
    validates :zip_code, presence: true, format: { with: VALID_ZIP_REGEX }

    def remote_validate
        return { response_type: :form_invalid_response,
            validated_address: nil } unless valid?
        
        validate_address(self)
    end
        
    # This save method is used when validating locally
    # It uses the StreetAddress gem.
    # Note StreetAddress Gem is not completely reliable
    def save
        return false unless valid?

        Address.find_or_create_by(address_model)
    end

    private
    
    def address_model
        parse_address_1(self)
    end

    def form_invalid_response(validated_address)
        ValidationResponse.new('address_form')
    end

    def failed_response(validated_address)
        ValidationResponse.new('validation_failed',:info,
             "So Sorry, something went wrong. Please try Again.\
             If problem persists, don't hesitate to contact us!")
    end

    def invalid_response(validated_address)
        ValidationResponse.new('address_invalid',:warning,
             "Address is invalid!", self.as_json)
    end

    def valid_response(validated_address)
        address_model = save_address(validated_address)
        ValidationResponse.new('address_valid',:success,
             "Address is valid!", address_model.as_json)

    end

    def partial_response(validated_address)
        address_model = save_address(validated_address[:api_address])
        validated_address[:api_address] = address_model.as_json
        ValidationResponse.new('address_partially_valid',:info,
             "Address is invalid!", validated_address)
    end

    def save_address(validated_address)
        Address.where(validated_address).first_or_create(validated_address)
    end

  end

class ValidationResponse
    attr_accessor :partial_name, :flash_type, :flash_message, :address

    def initialize(partial_name, flash_type=nil, flash_message=nil, address=nil)
        @partial_name = partial_name
        @flash_type = flash_type
        @flash_message = flash_message
        @address = address
    end
end
