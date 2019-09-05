class JobApplicant
  include Mongoid::Document
  field :_id, type: String
  field :job_id, type: String
  field :handle, type: String
  field :notes, type: String
  field :create_dttm, type: Date
  field :cover_note, type: String
  field :answer_id, type: String
  field :bought, type: Boolean, :default  => false
  field :opened, type: Boolean, :default  => false
  field :short_listed, type: Boolean, :default => false
  field :archived, type: Boolean, :default => false
  field :applied, type: Boolean, :default => false
  field :pseudo_applied, type: Boolean, :default => false
  field :invited, type: Boolean, :default => false
  attr_accessible :_id,
                  :job_id,
                  :invited,
                  :handle,
                  :create_dttm,
                  :bought,
                  :opened,
                  :notes,
                  :short_listed,
                  :archived,
                  :applied,
                  :cover_note,
                  :answer_id
end