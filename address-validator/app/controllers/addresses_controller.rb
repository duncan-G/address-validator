class AddressesController < ApplicationController
    
    def index
      render 'new'
    end
  
    def new
      @address_form = AddressForm.new
      
      respond_to do |format|
        format.js { render 'new',
                    :locals => {:partial_name => params[:partial_name], :address => params[:address] } }
        
        format.html { render 'new',
                      :locals => {:partial_name => params[:partial_name] || 'address_form',
                                  :address => params[:address]} }
      end
    end
  
  
    def create
      @address_form = AddressForm.new(address_params)
      # Validate address
      validated_address = @address_form.remote_validate 
      # Save address if valid
      validation_response = @address_form.send validated_address[:response_type],
        validated_address[:validated_address]
      
      # Invalid form
      if validated_address[:response_type] == :form_invalid_response
        render 'new',
            :locals => {:partial_name => validation_response.partial_name,
            :address =>validation_response.address } 
      else
        respond_to do |format|
          # If js is enabled then load partial with ajax
          format.js { render 'new', 
                      :locals => {:partial_name => validation_response.partial_name,
                      :address =>validation_response.address } }
          # If js is not enabled then reload new page
          format.html { redirect_to new_address_url(@address_form, partial_name: validation_response.partial_name,
            address: validation_response.address) }
        end
      end
    end
  
    private
  
    def address_params
      params.require(:address_form).permit(:street_address, :city, :state, :zip_code)
    end
  end
  