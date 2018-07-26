class Address < ApplicationRecord
  validates :house_number, presence: true
  validates :street_name, presence: true
  validates :street_type, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_5, presence: true;

  def to_s
    # TODO: override the to_s method so that it prints out the address components as follows
    # house_number street_predirection street_name street_type street_postdirection unit_type unit_number, city, state, zip_5
    first_line = [house_number, street_predirection, street_name, street_type,
                  street_postdirection, unit_type, unit_number]
    second_line = [city, state, zip_5]

    first_line.delete(nil)
    second_line.delete(nil)

    first_line.join(' ') + ', ' + second_line.join(', ')
  end
end 