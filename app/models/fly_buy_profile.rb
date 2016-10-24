# == Schema Information
#
# Table name: fly_buy_profiles
#
#  id                          :integer          not null, primary key
#  synapse_user_id             :string
#  user_id                     :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  encrypted_fingerprint       :string
#  synapse_node_id             :string
#  synapse_ip_address          :string
#  eic_attachment_file_name    :string
#  eic_attachment_content_type :string
#  eic_attachment_file_size    :integer
#  eic_attachment_updated_at   :datetime
#  synapse_document_id         :string
#  bank_statement_file_name    :string
#  bank_statement_content_type :string
#  bank_statement_file_size    :integer
#  bank_statement_updated_at   :datetime
#  gov_id_file_name            :string
#  gov_id_content_type         :string
#  gov_id_file_size            :integer
#  gov_id_updated_at           :datetime
#  permission_scope_verified   :boolean          default(FALSE)
#  kba_questions               :json
#  terms_of_service            :boolean          default(FALSE)
#  name_on_account             :string
#  ssn_number                  :string
#  date_of_company             :datetime
#  dob                         :datetime
#  entity_type                 :string
#  entity_scope                :string
#  company_email               :string
#  tin_number                  :string
#  completed                   :boolean          default(FALSE)
#

class FlyBuyProfile < ActiveRecord::Base
  belongs_to :user

  # attr_accessor :name_on_account, :account_num, :routing_num, :bank_name, :address,
  #                 :ssn_number, :date_of_company, :entity_type, :entity_scope,
  #                 :company_email, :company_address, :tin_number, :dob, :o_entity_type,
  #                 :question_1, :question_2, :question_3, :question_4, :question_5,
  #                 :company_phone, :o_entity_scope

  attr_accessor :account_num, :routing_num, :bank_name, :address, :email,
                  :question_1, :question_2, :question_3, :question_4, :question_5

  EscrowNodeID = '57d7465386c2732e824b7c8b'
  AppUserId = '57d745ff86c27319cbe0edf0'
  AppFingerPrint = '8781321799f523327fb8d1f15ffa266d'

  has_attached_file :eic_attachment
  has_attached_file :bank_statement
  has_attached_file :gov_id
  do_not_validate_attachment_file_type :eic_attachment
  do_not_validate_attachment_file_type :bank_statement
  do_not_validate_attachment_file_type :gov_id
end
