class Kudos
  include Mongoid::Document
  include LinkHelper
  field :handle, type: String
  field :giver_handle, type: String
  field :feed_id, type: String
  field :subject_id, type: String
  field :subject_type, type: String
  field :create_dttm, type: Date

  attr_accessible :handle, :create_dttm, :subject_id, :subject_type, :feed_id, :giver_handle
  set_callback(:save, :after) do |document|
  end
end