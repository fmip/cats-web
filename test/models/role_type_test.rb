# == Schema Information
#
# Table name: role_types
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  created_by  :integer
#  modified_by :integer
#  deleted     :boolean          default(FALSE)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class RoleTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
