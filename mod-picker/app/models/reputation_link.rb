class ReputationLink < ActiveRecord::Base
  self.primary_keys = :from_rep_id, :to_rep_id

  belongs_to :from_rep, :class_name => 'UserReputation', :inverse_of => 'reputation_given'
  belongs_to :to_rep, :class_name => 'UserReputation', :inverse_of => 'reputation_recieved'
end
