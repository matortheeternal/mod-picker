class BaseReport < ActiveRecord::Base
  belongs_to :reportable, :polymorphic => true
  has_many :reports, :inverse_of => 'base_report'
end
