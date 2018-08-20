require 'geocode/client'

class MakeGeoRequestJob < ApplicationJob
  queue_as :default

  def perform(full_address)
    client = Geocode::Client.new
    client.validate_address(full_address)
  end
end
