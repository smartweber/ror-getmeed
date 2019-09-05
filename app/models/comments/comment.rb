class Comment
  include Mongoid::Document
  field :description, type: String
  field :feed_id, type: String
  field :commenter_tagline, type: String
  field :create_time, type: Date, default: -> { Time.zone.now }
  field :poster_id, type: String
  field :poster_type, type: String
  field :upvote_count, type: Integer, default: 0
  field :downvote_count, type: Integer, default: 0
  field :lang_type, type: String
  field :code_description, type: String
  field :gist_id, type: String


  attr_accessible :description, :create_time,
                  :poster_id, :feed_id, :poster_type,
                  :upvote_count, :lang_type,
                  :commenter_tagline,
                  :code_description,
                  :upvote_count, :gist_id
end