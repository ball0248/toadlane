# == Schema Information
#
# Table name: inspection_dates
#
#  id             :integer          not null, primary key
#  date           :datetime
#  creator_type   :string
#  product_id     :integer
#  armor_order_id :integer
#  approved       :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class InspectionDate < ActiveRecord::Base
  belongs_to :product, class_name: 'Product', foreign_key: 'product_id'
  belongs_to :armor_order, class_name: 'ArmorOrder', foreign_key: 'armor_order_id'

  scope :approved, -> { where(approved: true) }
  scope :not_marked_approved, -> { where(approved: nil) }
  scope :seller_added, -> { where(creator_type: "seller") }
  scope :buyer_added, -> { where(creator_type: "buyer") }

  # gives August 09, 2016, 06:00 PM
  def get_inspection_date
    date.strftime("%B %d, %Y, %I:%M %p")
  end
end
