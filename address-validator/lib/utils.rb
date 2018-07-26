require 'street_address'
require 'geocode_api/client'
require 'geocode_api/response_helper'
require 'amatch'

module Utils
    include Amatch
    ## Globals ##
    @@api_client = Geocode::Client.new

    # Response types
    @@failed = :failed_response # Failed to validate -> bugs
    @@invalid = :invalid_response # Submitted address is invalid
    @@partial = :partial_response # Submitted address is almost correct
    @@success = :valid_response # Submitted address is valid

    # Use an API to validate the address
    # Return Address model params
    def validate_address(form)
        full_address = form.street_address + ' ' + [form.city, form.state, form.zip_code].join(', ')
        response = @@api_client.validate_address(full_address)


        if response["status"] == "ZERO_RESULTS"
            return { response_type: @@invalid,
                     validated_address: nil }

        elsif response["status"] == "APP_ERROR"
            return { response_type: @@failed,
                     validated_address: nil }

        elsif response["status"] == "OK"
            validated_address = ApiUtils.response_helper(response,form.street_address)
            address_model = Address.new(validated_address)
    
            return { response_type: @@invalid,
                     validated_address: nil } unless address_model.valid?

            partial = check_partial_address(form, address_model)
            if partial.empty? 
                return { response_type: @@success,
                     validated_address: validated_address }
            else
                hash = { response_type: @@partial,
                         validated_address: {
                            form_address: form.as_json, 
                            api_address: validated_address,
                            partial: partial
                            }
                        }
                return hash
            end
                    
        else
            # Aww something went really wrong here.
            # Log this
            return { response_type: @@failed,
                     validated_address: nil }
        end

    end

    def extract_street_address(validated_address)
        va_street_address = [validated_address.house_number, validated_address.street_predirection, 
            validated_address.street_name, validated_address.street_type,
            validated_address.street_postdirection, validated_address.unit_type, 
            validated_address.unit_number]
        va_street_address.delete(nil)
        va_street_address.join(' ')
    end

    # If 2 fields are not similar, then the inputed address
    # is partially valid
    def check_partial_address(form,validated_address)
        partial = []
        
        if !state_similar(form.state, validated_address.state)
            partial << "state"
        end

        if !city_similar(form.city, validated_address.city)
            partial << "city"
        end

        zip_5_similar, zip_4_similar = zip_similar(form.zip_code,
            validated_address.zip_5, validated_address.zip_4)
        if !zip_5_similar
            partial << "zip_5"
        end
        if !zip_4_similar
            partial << "zip_4"
        end

        va_street_address = extract_street_address(validated_address)        
        if !street_similar(form.street_address,va_street_address)
            partial << "street_address"
        end

        partial
    end

    # State
    def state_similar(form_state,va_state)
        return false if va_state.nil?
        return form_state == va_state
    end

    # City
    # If jarowinkler distance > 0.9, then the inputted city
    # is similar to the output
    def city_similar(form_city,va_city)
        return false if va_city.nil?
        return va_city.jarowinkler_similar(form_city) > 0.9 ? true : false
    end

    # Zip Code
    def zip_similar(form_zip, va_zip_5, va_zip_4)
        return false if va_zip_5.nil?
        
        form_zip_5,form_zip_4 = form_zip.split('-')

        zip_5_similar = form_zip_5 ==  form_zip_5 
        
        if !va_zip_4.nil? && !form_zip_4.nil?
            zip_4_similar = va_zip_4 == form_zip_4
        else
            # if input zip_4 or output zip_4 are nil, then
            # ignore this case and simply return true
            zip_4_similar = true
        end

        [zip_5_similar,zip_4_similar]
    end

    # Street addresss
    # If jarowinkler distance > 0.8, then the inputted street address
    # is similar to the output
    def street_similar(form_street_address,va_street_address)
        return false if va_street_address.nil?
        return va_street_address.jarowinkler_similar(form_street_address) > 0.8 ? true : false
    end

    # Return Address model params
    # StreetAddress Gem. Will return nil if given a county as well 
    # mis-categorizes categories such as street_postdirection and street_type.
    # Fails in many other cases. Use for testing
    def parse_address_1(form)
        address_as_string = form_to_string(form)
        parsed_address = StreetAddress::US.parse(address_as_string)
        {
            house_number: parsed_address.number,
            street_name: parsed_address.street,
            street_type: parsed_address.street_type,
            street_predirection: parsed_address.prefix,
            street_postdirection: parsed_address.suffix,
            unit_number: parsed_address.unit,
            unit_type: parsed_address.unit_prefix,
            city: parsed_address.city,
            county: nil,
            state: parsed_address.state,
            zip_5: parsed_address.postal_code,
            zip_4: parsed_address.postal_code_ext
        }
    end

    def form_to_string(form)
        form_array = [form.street_address,
                      form.city,
                      form.state,
                      form.zip_code]
        form_array.join(', ')
    end
end