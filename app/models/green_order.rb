# == Schema Information
#
# Table name: green_orders
#
#  id                   :integer          not null, primary key
#  buyer_id             :integer
#  seller_id            :integer
#  product_id           :integer
#  check_number         :string
#  check_id             :string
#  status               :integer          default(0)
#  unit_price           :float
#  count                :integer
#  fee                  :float
#  rebate               :float
#  total                :float
#  summary              :string(100)
#  description          :text
#  tracking_number      :string
#  deleted              :boolean          default(FALSE), not null
#  shipping_cost        :float
#  address_name         :string
#  address_city         :string
#  address_state        :string
#  address_zip          :string
#  address_country      :string
#  shipping_estimate_id :integer
#  address_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class GreenOrder < ActiveRecord::Base
  MAX_AMOUNT = 25000.00

  # Used to breakdown and deduct the amount from max for Green By Phone
  PRICE_BREAK_MULTIPLIER = 98.25

  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :product
  belongs_to :shipping_estimate
  belongs_to :address
  has_many :notifications, dependent: :destroy

  has_one :refund_request, -> { where deleted: false }
  has_many :green_checks, dependent: :destroy

  attr_accessor :name, :email_address, :phone, :address1, :address2, :routing_number, :account_number, :rebate_percent

  scope :for_dashboard, -> (page, per_page) do
    where(deleted: false).order('created_at DESC').paginate(page: page, per_page: per_page)
  end

  # not_started must be first (ie. at index 0) for the default value to be correct
  enum status: [ :not_started, :started, :shipping_estimate, :cancelled, :placed, :shipped, :completed, :challenged, :refunded ]

  # green_params: Hash    is the input from buyer
  # seller_id:    Integer is required to pay to their account
  # amount:       Float   is the amount to be transferred from buyer to seller
  # RETURNS:      Hash    includes responses from the API request
  def self.make_request(green_params = {}, seller_id = nil, product_id = nil, buyer_id = nil, amount = 0.0)
    seller = User.find_by_id(seller_id)
    green_profile = seller.try(:green_profile)
    if seller.present? && green_profile.present?
      api_params = green_api_ready_params(
        green_params,
        product_id,
        buyer_id,
        amount
      )
      green_service = GreenService.new(
        green_profile.green_client_id,
        green_profile.green_api_password
      )
      green_service.cart_check(api_params)
    else
      {
        "Result" => "404",
        "ResultDescription" => "Seller not found or invalid Green Profile",
        "CheckNumber" => "",
        "Check_ID": ""
      }
    end
  end

  def place_order
    product.sold_out += count
    self.product.save
    if shipping_estimate.nil?
      raise "No shipping estimate."
    end
    self.placed!
    self.save
  end

  def cancel_order
    product.sold_out -= count
    self.product.save
    self.cancelled!
    self.save
  end

  def check_cancel
    green_profile = seller.try(:green_profile)
    if seller.present? && green_profile.present?
      green_service = GreenService.new(
        green_profile.green_client_id,
        green_profile.green_api_password
      )
      green_service.cart_check_cancel({ "Check_ID" => "#{self.check_id}" })
    else
      {
        "Result" => "404",
        "ResultDescription" => "Seller not found or invalid Green Profile"
      }
    end
  end

  def check_status
    green_profile = seller.try(:green_profile)
    if seller.present? && green_profile.present?
      green_service = GreenService.new(
        green_profile.green_client_id,
        green_profile.green_api_password
      )
      green_service.cart_check_status({ "Check_ID" => "#{self.check_id}" })
    else
      {
        "Result" => "404",
        "ResultDescription" => "Seller not found or invalid Green Profile"
      }
    end
  end

  def process_checks_breakdown
    amount = self.total
    if amount > GreenOrder::MAX_AMOUNT
      amount = amount - GreenOrder::MAX_AMOUNT
      index = 1
      until amount == 0 do
        if amount > GreenOrder::MAX_AMOUNT
          amount_to_transfer = GreenOrder::MAX_AMOUNT - ( index * GreenOrder::PRICE_BREAK_MULTIPLIER )
        else
          amount_to_transfer = amount
        end
        self.delay.process_each_check(amount_to_transfer, {
          name: name,
          email_address: email_address,
          phone: phone,
          address1: address1,
          address2: address2,
          routing_number: routing_number,
          account_number: account_number,
          rebate_percent: rebate_percent
        })
        amount = amount - amount_to_transfer
        index += 1
      end
    end
  end

  def process_each_check(amount, form_hash = {})
    green_order_attributes = self.attributes.with_indifferent_access
    green_order_attributes.merge!(form_hash)
    response = GreenOrder.make_request(
      green_order_attributes,
      green_order_attributes[:seller_id],
      green_order_attributes[:product_id],
      green_order_attributes[:buyer_id],
      amount
    )
    self.green_checks.create({
      result: response['Result'],
      result_description: response['ResultDescription'],
      check_id: response['Check_ID'],
      check_number: response['CheckNumber'],
      amount: amount
    })
  end

  def total_price
    unit_prices = (count.to_f * unit_price.to_f)
    
    unit_prices + shipping_cost.to_f - (unit_prices * rebate.to_f / 100)
  end

  private_class_method
  def self.has_green_bank_info?(green_params)
    ![green_params[:routing_number], green_params[:account_number], green_params[:bank_name]].any? {|p| p.blank?}
  end

  def self.green_api_ready_params(green_params, product_id, buyer_id, amount)
    api_ready_params = {}
    api_ready_params["Name"] = "#{green_params[:name]}"
    api_ready_params["EmailAddress"] = "#{green_params[:email_address]}"
    api_ready_params["Phone"] = "#{green_params[:phone]}"
    api_ready_params["PhoneExtension"] = ""
    api_ready_params["Address1"] = "#{green_params[:address1]}"
    api_ready_params["Address2"] = "#{green_params[:address2]}"
    api_ready_params["City"] = "#{green_params[:address_city]}"
    api_ready_params["State"] = "#{green_params[:address_state].try(:upcase)}"
    api_ready_params["Zip"] = "#{green_params[:address_zip]}"
    api_ready_params["Country"] = "#{green_params[:address_country]}"
    api_ready_params["RoutingNumber"] = "#{green_params[:routing_number]}"
    api_ready_params["AccountNumber"] = "#{green_params[:account_number]}"
    api_ready_params["BankName"] = "#{green_params[:bank_name]}"
    api_ready_params["CheckMemo"] = "p:#{product_id}u:#{buyer_id}t:#{Time.now.to_i}"
    api_ready_params["CheckAmount"] = "#{amount.round(2)}"
    api_ready_params["CheckDate"] = "#{Time.now.strftime("%m/%d/%Y")}"
    api_ready_params["CheckNumber"] = ""
    api_ready_params
  end

  def self.pending_orders
    all - completed - refunded
  end

  def get_toadlane_fee
    Fee.find_by(:module_name => "Green").value
  end

  def total_earning
    get_toadlane_fee.present? ? total - get_toadlane_fee - fee : total - fee
  end
end
