class LibTestHelper

    def self.sample_street_address
        "1820 California Blvd, San Luis Obispo, CA 93401, USA"
    end

    def self.sample_response
        {"results"=> [{"address_components"=> [{"long_name"=> "1820",
                            "short_name"=> "1820",
                            "types"=> ["street_number"]},
                        {"long_name"=> "California Boulevard",
                            "short_name"=> "California Blvd",
                            "types"=> ["route"]},
                        {"long_name"=> "San Luis Obispo",
                            "short_name"=> "San Luis Obispo",
                            "types"=> ["locality", "political"]},
                        {"long_name"=> "San Luis Obispo County",
                            "short_name"=> "San Luis Obispo County",
                            "types"=> ["administrative_area_level_2", "political"]},
                        {"long_name"=> "California",
                            "short_name"=> "CA",
                            "types"=> ["administrative_area_level_1", "political"]},
                        {"long_name"=> "United States",
                            "short_name"=> "US",
                            "types"=> ["country", "political"]},
                        {"long_name"=> "93401",
                            "short_name"=> "93401",
                            "types"=> ["postal_code"]},
                        {"long_name"=> "1110",
                            "short_name"=> "1110",
                            "types"=> ["postal_code_suffix"]}],
                        "formatted_address"=> "1820 California Blvd, San Luis Obispo, CA 93401, USA",
                        "geometry"=> {"location"=> {"lat"=> 35.2845888, "lng"=> -120.6526279},
                        "location_type"=> "RANGE_INTERPOLATED",
                        "viewport"=> {"northeast"=> {"lat"=> 35.2859377802915,
                            "lng"=> -120.6512789197085},
                            "southwest"=> {"lat"=> 35.28323981970851, "lng"=> -120.6539768802915}}},
                        "place_id"=> "EjQxODIwIENhbGlmb3JuaWEgQmx2ZCwgU2FuIEx1aXMgT2Jpc3BvLCBDQSA5MzQwMSwgVVNBIhsSGQoUChIJhTjDNA_x7IARL0CWc9ye8YwQnA4",
                        "types"=> ["street_address"]}],
                        "status"=> "OK"}
    end

    def self.sample_piped_response
        {
        "house_number"=> "1820",
        "city"=> "SAN LUIS OBISPO",
        "county"=> "SAN LUIS OBISPO COUNTY",
        "state"=> "CA",
        "zip_5"=> "93401",
        "zip_4"=> "1110",
        "route"=> "CALIFORNIA BLVD"
        }
    end

    def self.sample_address
        {
            "house_number"=> "1820",
            "street_name"=> "CALIFORNIA",
            "street_type"=> "BLVD",
            "street_predirection"=> nil,
            "street_postdirection"=> nil,
            "unit_number"=> nil,
            "unit_type"=> nil,
            "city"=> "SAN LUIS OBISPO",
            "county"=> "SAN LUIS OBISPO COUNTY",
            "state"=> "CA",
            "zip_5"=> "93401",
            "zip_4"=> "1110"
        }
    end

    def self.sample_street_addresses
        [["a string apt 4", "APT"], ["a string APT 4", "APT"],
        ["a string APT4E", "APT"], ["a string Apt. 4", "APT"],
        ["a string STE 4", "STE"], ["a string SUITE. 4", "STE"],
        ["a string suite554", "STE"], [ "a string ste. 4", "STE"]]
    end

    def self.directions
        ["N","S","E","W","NE","NW","SE","SW"]
    end

    def self.street_types
        ["AVE","ALY","BLVD","CSWY","CIR","CT","CV","CRES","DR","HWY",
         "LN","LOOP","MHP","PARK","PKWY","SQ","ST","TER","TRL",
         "TRCE","WAY"]
    end

    def self.sample_street_names
        ["California","Ocean","1st","43","Cirle","Rounding","Living", "Martin Luther"]
    end

    def self.sample_routes
        directions = directions() << nil << nil  << nil
        street_types = street_types()
        street_names = sample_street_names()

        routes = []
        (1..30).each do |_|
            street_predirection = directions.sample
            street_postdirection = directions.sample
            street_type= street_types.sample
            street_name = sample_street_names.sample

            routes << {
                "street_predirection"=> street_predirection,
                "street_postdirection"=> street_postdirection,
                "street_type"=> street_type,
                "street_name"=> street_name,
                "street_address"=> ["#{street_predirection ||''}", street_name, 
                    street_type, "#{street_postdirection ||''}"].join(" ")
               }
            end
        routes
    end

    def self.work
        puts 'working'
    end
end