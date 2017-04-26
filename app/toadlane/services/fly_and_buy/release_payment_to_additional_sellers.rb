module Services
  module FlyAndBuy

    class ReleasePaymentToAdditionalSellers < Base

      attr_accessor :user, :fly_buy_profile, :fly_buy_order, :synapse_pay

      def initialize(user, fly_buy_profile, fly_buy_order)
        @user = user
        @fly_buy_profile = fly_buy_profile
        @fly_buy_order = fly_buy_order

        @synapse_pay = Services::SynapsePay.new(fingerprint: Services::SynapsePay::FINGERPRINT, ip_address: fly_buy_profile.synapse_ip_address)
      end

      def process
        synapse_user = synapse_pay.user(user_id: Services::SynapsePay::USER_ID)
        node = synapse_user.find_node(id: Services::SynapsePay::ESCROW_NODE_ID)

        additional_sellers = fly_buy_order.additional_seller_fee_transactions
        a = 0

        additional_sellers.each do |additional_seller|
          unless additional_seller.fee.zero?
            transaction = node.create_transaction(transaction_settings(additional_seller))

            a += 1 if transaction.recent_status['status'] == 'CREATED'
          end
        end

        # if additional_sellers.count == a
        #   fly_buy_order.update_attribute(:payment_released_to_group, true)
        # end
      end

      private

      def transaction_settings(additional_seller)
        file = convert_invoice_to_image(fly_buy_order, user)
        additional_seller_profile = additional_seller.user.fly_buy_profile

        {
          to_type:      seller_account_type(additional_seller_profile),
          to_id:        additional_seller_profile.synapse_node_id,
          amount:       additional_seller.fee,
          currency:     SynapsePay::CURRENCY,
          ip:           fly_buy_profile.synapse_ip_address,
          process_in:   0,
          note:         'Released Payment To Additional Seller',
          attachments:  [encode_file(file: file, type: 'image/png')],
          supp_id:      "FlyBuyOrder::AdditionalSellerFee-#{additional_seller.id}"
        }
      end
    end
  end
end