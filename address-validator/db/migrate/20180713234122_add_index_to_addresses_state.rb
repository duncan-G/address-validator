class AddIndexToAddressesState < ActiveRecord::Migration[5.1]
  def change
    add_index :addresses, [:state, :city]
  end
end
