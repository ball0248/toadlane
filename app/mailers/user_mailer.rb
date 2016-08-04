class UserMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default from: 'Toadlane Notifications hello@toadlane.com'

  def event_notification_user(user, token)
    email = user.email
    @token = token
    @user = user
    mail to: email, subject: 'New event - Add User Account'
  end

  def event_notification_admin(user, token)
    email = user.email
    @token = token
    @user = user
    mail to: email, subject: 'New event - Add Admin Account'
  end

  def sales_order_notification_to_seller(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @seller.email, subject: 'You have a sales order!!!'
  end

  def sales_order_notification_to_buyer(order)
    @order = order
    @seller = User.find_by_id(@order.seller_id)
    @buyer = User.find_by_id(@order.buyer_id)
    @product = Product.find_by_id(@order.product_id)

    mail to: @buyer.email, subject: 'Your order has been placed!!!'
  end

  def order_canceled_notification_to_seller(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has canceled an order!!!"
  end

  def refund_request_notification_to_seller(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has requested refund for an order!!!"
  end

  def refund_request_accepted_notification_to_buyer(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @buyer.email, subject: 'Your refund request has been accepted!!!'
  end

  def refund_request_rejected_notification_to_buyer(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @buyer.email, subject: 'Your refund request has been rejected!!!'
  end

  def refund_request_canceled_notification_to_seller(stripe_order)
    @stripe_order = stripe_order
    @seller = User.find_by_id(@stripe_order.seller_id)
    @buyer = User.find_by_id(@stripe_order.buyer_id)
    @product = Product.find_by_id(@stripe_order.product_id)

    mail to: @seller.email, subject: "#{@buyer.name} has canceled a refund request!!!"
  end

  def send_confirmation_email(user, product = nil, armor_order = nil)
    @product = product
    @armor_order = armor_order
    mail to: user.email, subject: "Confirmation email"
  end

  def send_inspection_date_set_notification_to_seller(armor_order)
    @armor_order = armor_order
    @seller = User.find_by_id(@armor_order.seller_id)
    @buyer = User.find_by_id(@armor_order.buyer_id)
    @product = Product.find_by_id(@armor_order.product_id)

    mail to: @seller.email, subject: "#{@seller.name} has requested to set inspection date"
  end

  def send_inspection_date_set_notification_to_buyer(armor_order)
    @armor_order = armor_order
    @seller = User.find_by_id(@armor_order.seller_id)
    @buyer = User.find_by_id(@armor_order.buyer_id)
    @product = Product.find_by_id(@armor_order.product_id)

    mail to: @buyer.email, subject: "#{@buyer.name} has responded to inspection date that you set"
  end

  def send_inspection_date_confirm_notification_to_buyer(armor_order)
    @armor_order = armor_order
    @seller = User.find_by_id(@armor_order.seller_id)
    @buyer = User.find_by_id(@armor_order.buyer_id)
    @product = Product.find_by_id(@armor_order.product_id)

    mail to: @buyer.email, subject: "#{@buyer.name} has confirmed the inspection date"
  end
end
