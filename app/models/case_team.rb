
# == Schema Information
#
# Table name: case_teams
#
#  id          :integer          not null, primary key
#  name        :string
#  discription :string
#  created_by  :integer
#  modified_by :integer
#  deleted     :boolean          default(FALSE)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CaseTeam < ApplicationRecord
     belongs_to :role_type
end
