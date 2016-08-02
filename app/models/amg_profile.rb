# == Schema Information
#
# Table name: amg_profiles
#
#  id          :integer          not null, primary key
#  amg_api_key :string
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AmgProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :amg_api_key
  validates_uniqueness_of :amg_api_key
end
