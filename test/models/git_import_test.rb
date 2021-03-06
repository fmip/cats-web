# == Schema Information
#
# Table name: git_imports
#
#  id                     :integer          not null, primary key
#  gin                    :string
#  hub                    :string
#  requisition_no         :string
#  round                  :string
#  region                 :string
#  zone                   :string
#  woreda                 :string
#  fdp                    :string
#  transporter            :string
#  driver                 :string
#  plat_no                :string
#  trailer_no             :string
#  dispatch_date          :string
#  project_code           :string
#  commodity_class        :string
#  commodity_type         :string
#  rounded_allocation_mt  :string
#  total_units_dispatched :string
#  quintals_dispatched    :string
#  mt_dispatched          :string
#  allocation_period      :string
#  storekeeper            :string
#  store_no               :string
#  remark                 :string
#  created_by             :integer
#  modified_by            :integer
#  deleted                :boolean          default(FALSE)
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  imported               :boolean
#

require 'test_helper'

class GitImportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
