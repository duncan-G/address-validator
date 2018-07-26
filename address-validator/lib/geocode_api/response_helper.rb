class ApiUtils
    #
    # @param(response) feild from geocode response object
    # @param(street_adddres) field from AddressForm
    #
    def self.response_helper(response, street_address)
        address = {
            "house_number"=> nil,
            "street_name"=> nil,
            "street_type"=> nil,
            "street_predirection"=> nil,
            "street_postdirection"=> nil,
            "unit_number"=> nil,
            "unit_type"=> nil,
            "city"=> nil,
            "county"=> nil,
            "state"=> nil,
            "zip_5"=> nil,
            "zip_4"=> nil
        }
        
        # Turn "address_components" array into hash and upcase all fields
        results = restructer_response(response)

        # delete 'route' field from hash and update address hash
        route = results.delete("route")
        address.update(results)

        # update address hash with street address info
        address.update(route_helper(route))

        # update address hash with unit type
        address["unit_type"] = unit_type_helper(street_address)
        # remove apt/ste from unit number if there
        address["unit_number"] = unit_number_helper(address["unit_number"])

        return address
    end

    def self.restructer_response(response)
        pipe = {
            "street_number" => "house_number",
            "subpremise" => "unit_number",
            "locality" => "city",
            "administrative_area_level_2" => "county",
            "administrative_area_level_1" => "state",
            "postal_code" => "zip_5",
            "postal_code_suffix" => "zip_4",
            "route" => "route"
        }

        address_object = {}
        response["results"][0]["address_components"].each do |address_component|
            pipe.keys.any? { |i|
                if address_component["types"].include? i
                    address_object[pipe[i]] = address_component["short_name"].upcase
                end
                }
        end
        
        return address_object
    end

    # Extract unit type
    # @param(street_address) field from AddressForm
    #
    def self.unit_type_helper(street_address)
        unit_types = {
            "STE"=> "STE",
            "SUITE"=> "STE", # using SUITE instead of abbreviation is common
            "APT"=> "APT"
        }
        # match apt or ste or suite + optional dot + number or space
        unit_type_regex = /(apt|ste|suite)+(\.)?+(\s|[0-9])/i
        address = street_address.upcase
        matches = address.scan(unit_type_regex)
        unit_type = nil
        if !!matches
            unit_types.keys.each do |key|
                matches.each do |match|
                    if match.include?(key)
                        unit_type = unit_types[key]
                        break
                    end
                end
            end
        end

        return unit_type
    end

    # Remove apt/ste from subpremise if it is there
    def self.unit_number_helper(subpremise)
        return subpremise if subpremise.nil?

        subpremise.gsub!('.',' ') #Replace all dots with spaces if exist
        subpremise.squish! # Remove double space if created from replacement
        
        ['APT','STE'].any? { |str| 
            if subpremise.include? str
                subpremise.sub!(str + ' ','')
            end
        }
        subpremise
    end


    # Extract street_predirection, street_postdirection, street_type, street_type
    # @param(route) field from geocode response object
    #
    def self.route_helper(route)
        # Geocode could not get a route from
        if route.nil?
            return {}
        end

        street_predirection = nil
        street_postdirection = nil
        street_type = nil
        steet_name = nil

        directions = ["N","S","E","W","NE","NW","SE","SW"]
        street_types = ["AVE","ALY","BLVD","CSWY","CIR","CT","CV","CRES","DR","HWY",
                        "LN","LOOP","MHP","PARK","PKWY","PL","PLZ","RD","SQ","ST","TER","TRL",
                        "TRCE","WAY"]
        route_array = route.split(' ')

        # Check if a direction is at the beggining and remove from array
        if directions.include?(route_array[0].upcase)
            street_predirection = route_array[0]
            route_array.delete_at(0)
        end

        # Check if a direction is at the end and remove from array
        if directions.include?(route_array[-1].upcase)
            street_postdirection = route_array[-1]
            route_array.delete_at(-1)
        end

        # Check for street type at the end and remove from array
        if street_types.include?(route_array[-1].upcase)
            street_type = route_array[-1]
            route_array.delete_at(-1)
        end
        
        # Street name is the remainder of the array
        street_name = route_array.join(' ')

        return {
         "street_predirection"=> street_predirection,
         "street_postdirection"=> street_postdirection,
         "street_type"=> street_type,
         "street_name"=> street_name
        }
    end
end

