class Dashboard::AccountsController < DashboardController
  include ProductHelper

  def index
    set_user
    set_green_profile
    set_profile_for_armor
    # if current_user.armor_profile.present? && current_user.armor_profile.armor_account_id.present?
    #   client = ArmorService.new
    #   account_id = current_user.armor_profile.armor_account_id
    #   user_id = current_user.armor_profile.armor_user_id
    #   response = client.accounts.bankaccounts(account_id).all
    #   uri = response.data[:path]
    #   auth_data = {     'uri' => uri,     'action' => 'create' }
    #   result = client.users(account_id).authentications(user_id).create(auth_data)
    #   @url = result.data[:body]["url"]
    # end
  end

  def create_green_profile
    if green_params.present?
      green_profile = GreenProfile.new(green_params)
      if green_profile.valid?
        current_user.green_profile = green_profile
        redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully created." }
      else
        redirect_to dashboard_accounts_path, :flash => { :alert => "#{green_profile.errors.full_messages.to_sentence}" }
      end
    else
      redirect_to dashboard_accounts_path, :flash => { :alert => "Green Profile not created, please try again." }
    end
  end

  def create_armor_profile
    if current_user.armor_profile.present?
      client = ArmorService.new
      email_confirmed = armor_params["confirmed_email"]
      agreed_terms = armor_params["agreed_terms"] == "1" ? true : false
      default_payment = armor_params["default_payment"] == "1" ? true : false

      current_user.armor_profile.update_attributes({
        agreed_terms: agreed_terms,
        default_payment: default_payment
      })

      phone_number = Phonelib.parse(armor_params["phone"])

      current_user.update_attributes({
        name: armor_params["name"],
        phone: phone_number,
        company: armor_params["company"],
      })

      if armor_params["addresses"].present?
        current_user.addresses.create(armor_params["addresses"])
        selected_address = current_user.addresses.first
      else
        selected_address = current_user.addresses.find_by_id(armor_params[:address_id])
      end


      account_data = {
                        "company" => armor_params["company"],
                        "user_name" => armor_params["name"],
                        "user_email" => armor_params["email"],
                        "user_phone" => phone_number.international,
                        "address" => selected_address.line1.present? ? selected_address.line1 : selected_address.line2,
                        "city" => selected_address.city,
                        "state" => get_state(selected_address.state),
                        "zip" => selected_address.zip,
                        "country" => selected_address.country.downcase,
                        "email_confirmed" => email_confirmed,
                        "agreed_terms" => agreed_terms }

      result = client.accounts.create(account_data)
      current_user.armor_profile.update_attribute(:armor_account_id, result.data[:body]["account_id"])

      users = client.users(current_user.armor_profile.armor_account_id).all
      current_user.armor_profile.update_attribute(:armor_user_id, users.data[:body][0]["user_id"].to_i)

      redirect_to :back, :flash => { :notice => "Armor Profile successfully created." }
    else
      redirect_to :back
    end
  rescue ArmorService::BadResponseError => e
    redirect_to :back, :flash => { :error => e.errors.values.flatten }
  end

  def send_confirmation_email
    product = Product.find_by_id(params[:product_id]) if params[:product_id].present?
    armor_order = ArmorOrder.find_by_id(params[:armor_order_id]) if params[:armor_order_id].present?
    email = UserMailer.send_confirmation_email(current_user, product, armor_order).deliver_now
    if product.present? && armor_order.present?
      redirect_to product_checkout_path(product_id: product.id, armor_order_id: armor_order.id), :flash => { :notice => "Confirmation email has been sent. Please check your email." }
    else
      redirect_to dashboard_accounts_path, :flash => { :notice => "Confirmation email has been sent. Please check your email." }
    end
  end

  def update
    if green_params.present?
      green_profile = current_user.green_profile
      green_profile.update_attributes(green_params)
      redirect_to dashboard_accounts_path, :flash => { :notice => "Green Profile successfully updated." }
    end
  end

  def set_armor_profile
    current_armor_profile = current_user.armor_profile
    if current_armor_profile.present?
      armor_profile = current_armor_profile
    elsif params[:confirmed_email].present? && current_armor_profile.nil?
      armor_profile = ArmorProfile.create(:confirmed_email => params[:confirmed_email], :user_id => current_user.id)
    else
      armor_profile = ArmorProfile.new
    end

    if params[:product_id].present? && params[:armor_order_id].present?
      redirect_to product_checkout_path(product_id: params[:product_id], armor_order_id: params[:armor_order_id], armor_profile_id: armor_profile.id), :flash => { :notice => "Your email has been confirmed successfully. fill up other details to create armor profile" }
    else
      redirect_to dashboard_accounts_path(armor_profile_id: armor_profile.id), :flash => { :notice => "Your email has been confirmed successfully. fill up other details to create armor profile" }
    end
  end

  private
    def set_user
      @user = current_user
    end

    def set_green_profile
      current_green_profile = current_user.green_profile
      if current_green_profile.present?
        @green_profile = current_green_profile
      else
        @green_profile = GreenProfile.new
      end
    end

    def set_profile_for_armor
      current_armor_profile = current_user.armor_profile
      if current_armor_profile.present?
        @armor_profile = current_armor_profile
      elsif params["armor_profile_id"].present?
        @armor_profile = ArmorProfile.find_by_id(params["armor_profile_id"])
      else
        @armor_profile = ArmorProfile.new
      end
    end

    def user_params
      params.require(:user).permit!
    end

    def green_params
      params.require(:green_profile).permit!
    end

    def armor_params
      params.require(:armor_profile).permit!
    end
end
