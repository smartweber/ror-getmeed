class UserFollowUser
  include Mongoid::Document
  include LinkHelper
  field :id, type: String
  field :follower_handle, type: String
  field :handle, type: String
  field :create_dttm, type: DateTime, default: Time.now

  attr_accessible :id, :follower_handle, :handle, :create_dttm


end