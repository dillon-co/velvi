# == Schema Information
#
# Table name: recruiters
#
#  id                           :integer          not null, primary key
#  name                         :string           default(""), not null
#  email                        :string           default(""), not null
#  encrypted_password           :string           default(""), not null
#  reset_password_token         :string
#  reset_password_sent_at       :datetime
#  remember_created_at          :datetime
#  sign_in_count                :integer          default(0), not null
#  current_sign_in_at           :datetime
#  last_sign_in_at              :datetime
#  current_sign_in_ip           :inet
#  last_sign_in_ip              :inet
#  address                      :string
#  parent_code                  :string
#  referral_code                :string
#  referred_user_purchases      :integer
#  referred_recruiter_purchases :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

require 'test_helper'

class RecruiterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
