module Services
  module Crud
    class Product
      attr_reader :product_params, :product
      ONE = '1'

      def initialize(product_params, current_user, id = nil)
        @product_params = product_params
        product_params[:group_attributes].merge!(group_owner_id: current_user.id)
        product_params[:inspection_dates_attributes].each {|key, value| value[:creator_type] = ::Product::SELLER}
        @product = if id.nil?
          product = current_user.products.new(params)
        else
          product = ::Product.where(id: id).first
          product.assign_attributes(product_params)
          product
        end
      end

      def save!
        ::Product.transaction do
          product.save!
        end
      end

      private

      def negotiable
        product_params["negotiable"] == ONE ? true : false
      end

      def parse_date_time(date)
        DateTime.strptime(date, '%Y-%m-%d %I:%M %p')
      end

      def params
        product_params.merge!(start_date: parse_date_time(product_params[:start_date]))
            .merge!(end_date: parse_date_time(product_params[:end_date]))
            .merge!(negotiable: negotiable)
      end
    end
  end
end