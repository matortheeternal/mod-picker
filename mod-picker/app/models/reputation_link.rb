class ReputationLink < ActiveRecord::Base
  belongs_to :from_rep, :class_name => 'UserReputation', :inverse_of => 'reputation_given'
  belongs_to :to_rep, :class_name => 'UserReputation', :inverse_of => 'reputation_recieved'
end
