class CustomSource < ActiveRecord::Base
  belongs_to :mod, :inverse_of => :custom_sources
end
