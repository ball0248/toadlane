class ProductsController < ApplicationController
  layout 'user_dashboard'

  before_action :check_terms_of_service

  def index    
    # TODO Disabling this during Stripe integration by calling for 'buy' only
    @products_recommended = Product.unexpired.where(status_characteristic: 'sell', status_action: 'recommended').order(created_at: :desc).limit(16)
    @products_for_sale = Product.unexpired.where(status_characteristic: 'sell').order(created_at: :desc).limit(16)
    # TODO Disabling this during Stripe integration by calling for 'buy' instead of 'sell'
    @products_requested = Product.unexpired.where(status_characteristic: 'sell').order(created_at: :desc).limit(16)
    @featured_sellers = User.limit(16)
  end

  def show
    set_product
    @stripe_order = StripeOrder.new
    @fee = Fee.find_by(:module_name => "Stripe").value
    commontator_thread_show(@product)
    @related_products = Product.unexpired.where(main_category: @product.main_category).where.not(id: @product.id)
  end

  def products
    @products = Product.unexpired.where(status_characteristic: 'sell').order('updated_at DESC').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
  end

  def deals
# TODO
  end
  
  def for_sale
    @products = Product.unexpired.where(status_characteristic: 'sell').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end
  
  def requested
    # TODO Disabling this during Stripe integration by calling for 'buy' instead of 'sell'
    @products = Product.unexpired.where(status_characteristic: 'buy').paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    render 'products/products'
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end
end
