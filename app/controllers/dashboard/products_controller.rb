class Dashboard::ProductsController < DashboardController
  def index
    @products = current_user.products.paginate(page: params[:page], per_page: params[:count]).order('id DESC')
    @products_count = @products.count
    @products.each do |product|
      if inactive_product? product
        product.update_attribute(:status, false)
      end
    end
  end

  def new
    if params[:product].present?
      @product = Product.new(product_params)
    else
      @product = Product.new
      group_builder = @product.build_group
      group_builder.group_sellers.build
    end
    @product.inspection_dates.build
    @product.pricebreaks.build
    expected_group_members(current_user)
  end

  def edit
    set_product
    raise 'Unauthorized user access!' unless authorized_user?
    if @product.group.blank?
      group_builder = @product.build_group
      group_builder.group_sellers.build
      expected_group_members(current_user)
    elsif
      group = @product.group
      group.group_sellers.build unless group.group_sellers.present?
      expected_group_members(group.owner)
    end

    @product.inspection_dates.build if @product.inspection_dates.blank?
    @product.pricebreaks.build if @product.pricebreaks.blank?
    @history = PaperTrail::Version.where(item_id: @product.id).order('created_at DESC')
  end

  def create
    product_service = Services::Crud::Product.new(product_params, current_user)
    @product = product_service.product
    respond_to do |format|
      if @product.valid?
        product_service.save!
        @product = product_service.product
        send_email_to_additional_sellers @product
        format.html { redirect_to after_create_and_update_path }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    product_service = Services::Crud::Product.new(product_params, current_user, params[:id])
    @product = product_service.product
    respond_to do |format|
      if @product.valid?
        product_service.save!
        @product = product_service.product
        send_email_to_additional_sellers @product
        format.html { redirect_to after_create_and_update_path }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    set_product
    send_product_deleted_message(@product)
    @product.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_products_path }
    end
  end

  def delete_cascade
    if params[:products_ids].present?
      params[:products_ids].each do |id|
        Product.find(id).destroy
      end
    end

    render json: :ok
  end

  def active_cascade
    if params[:products_ids].present?
      params[:products_ids].each do |id|
        product = Product.find(id)
        if active_product? product
          product.update(status: true)
        end
      end
    end

    render json: :ok
  end

  def inactive_cascade
    if params[:products_ids].present?
      params[:products_ids].each do |id|
        Product.find(id).update(status: false)
      end
    end

    render json: :ok
  end

  def viewers
    set_product
    user_ids = @product.impressions.try(:pluck, :user_id)
    if user_ids.include? @product.user.id
      user_ids.delete(@product.user.id)
    end
    @users = User.where(id: user_ids).order('id ASC')
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product)
    .permit(:id, :name, :negotiable, :description,
      :user_id, :unit_price, :status_action,
      :status, :status_characteristic, :start_date,
      :end_date, :amount, :sold_out, :dimension_width,
      :dimension_height, :dimension_depth,
      :dimension_weight, :main_category, { tag_list: []}, :default_payment, :fee_percent, :sku,
      :slug, images_attributes: [:id, :image, :product_id, :_destroy],
      :certificates_attributes => [:id, :uploaded_file, :_destroy],
      :videos_attributes => [:id, :video, :product_id, :_destroy], :videos_attributes_delete => [],
      :shipping_estimates_attributes => [ :id, :cost, :description, :product_id, :_destroy, :type ],
      :pricebreaks_attributes => [ :id, :quantity, :price, :product_id, :_destroy ], :inspection_dates_attributes => [:id, :date, :product_id, :_destroy],
      :product_categories_attributes => [:id, :product_id, :category_id],
      group_attributes: [:id, :name, :product_id, :_destroy, group_sellers_attributes: [:id, :group_id, :user_id, :fee, :_destroy, :role_id]]
    )
  end

  def parse_date_time(date)
    DateTime.strptime(date, '%Y-%m-%d %I:%M %p')
  end

  def after_create_and_update_path
    if params[:button] == 'new'
      path = new_dashboard_product_path
    elsif params[:button] == 'edit'
      path = edit_dashboard_product_path(@product.id)
    else
      path = dashboard_products_path
    end
  end

  def inactive_product? product
    !product.default_payment_flybuy? || !current_user.fly_buy_profile_account_added? || product.expired?
  end

  def active_product? product
    current_user.has_payment_account? && current_user.fly_buy_profile_account_added? && !product.expired?
  end

  def send_email_to_additional_sellers product
    return unless product.group.present?
    return unless product.group.group_sellers.present?
    group_sellers = product.group.group_sellers.where(notified: false)
    Services::Notifications::AdditionalSellerNotification.new(group_sellers, product, current_user).send
  end

  def authorized_user?
    product = Product.find(params[:id])
    group_seller = product.group.group_sellers.find_by_user_id(current_user.id) if product.group.present?
    (group_seller.present? && group_seller.is_group_admin?) || product.owner == current_user
  end

  def send_product_deleted_message(product)
    if product.group.present?
      product.group.group_sellers.each do |group_seller|
        admins = product.group_admins
        param_hash = {group: product.group.name, product: product, group_seller: group_seller.user, current_user: current_user, admins: product.group_admins}
        NotificationMailer.group_product_removed_notification_email(param_hash).deliver_later
      end
    end
  end
end
