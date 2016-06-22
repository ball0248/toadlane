class StripeOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service
  
  def show
    @stripe_order = StripeOrder.find(params[:id])
  end
 
  def create
    if params['paymentGateway'] == 'eCheck'
      unless green_params_valid?
        redirect_to :back, alert: "Missing required fields for eCheck."
        return
      end
      response = GreenOrder.make_request(
          green_params,
          stripe_order_params[:seller_id],
          stripe_order_params[:total]
      )
      if response['Result'] == '0'
        gop = green_order_params
        gop[:check_number] = response['CheckNumber']
        gop[:check_id] = response['Check_ID']
        @green_order = GreenOrder.new(gop)
        @green_order.save
        redirect_to dashboard_order_path, notice: "Your order was succesfully placed."
      else
        redirect_to :back, alert: "GreenByPhone Response: #{response['ResultDescription']}"
        return
      end
      # Create GreenOrder
      # Redirect
    elsif params['paymentGateway'] == 'Credit Card'
      @stripe_order = StripeOrder.new(stripe_order_params)
      @stripe_order.save
      @stripe_order.start_stripe_order(stripe_params["stripeToken"])

      if stripe_order_params[:address_id] == "-1"
        address = Address.new
        address.name = stripe_params["stripeShippingName"]
        address.line1 = stripe_params["stripeShippingAddressLine1"]
        address.line2 = stripe_params["stripeShippingAddressLine2"]
        address.zip = stripe_params["stripeShippingAddressZip"]
        address.state = stripe_params["stripeShippingAddressState"]
        address.city = stripe_params["stripeShippingAddressCity"]
        address.country = stripe_params["stripeShippingAddressCountry"]
        address.user = @stripe_order.buyer

        @stripe_order.address = address
      end

      @stripe_order.calculate_shipping()

      @stripe_order.process_payment()

      redirect_to dashboard_order_path(@stripe_order, :type => "stripe"), notice: "Your order was succesfully placed."
    else
      redirect_to :back, alert: "Payment Gateway not selected"
    end
  end
  
  private
    def stripe_order_params
      params.require(:stripe_order).permit(:id, :buyer_id, :seller_id, :product_id, :stripe_charge_id, :status, :unit_price, :count, :fee, :rebate, :total, :summary,
                                           :description, :shipping_address, :shipping_request, :shipping_details, :tracking_number, :deleted, :shipping_cost,
                                           :address_name, :address_city, :address_state, :address_country, :address_zip, :address_id, :shipping_estimate_id)
    end
    
    def stripe_params
      params.permit(:stripeToken, :stripeEmail, :stripeShippingName, :stripeShippingAddressLine1, :stripeShippingAddressLine2,
                    :stripeShippingAddressZip, :stripeShippingAddressState, :stripeShippingAddressCity, :stripeShippingAddressCountry)
    end

    def green_params
      params.require(:green_order).permit(:name, :address1, :address2, :city, :state, :zip, :country, :routing_number, :account_number, :bank_name, :check_memo, :check_date, :check_number)
    end

    def green_params_valid?
      ![green_params[:name], green_params[:address1], green_params[:city], green_params[:state], green_params[:zip], green_params[:zip], green_params[:check_date], green_params[:check_number]].any? {|p| p.blank?}
    end

    def green_order_params
      stripe_order_params.except(:id, :stripe_charge_id)
    end

end