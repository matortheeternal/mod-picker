module Reportable
  extend ActiveSupport::Concern

  included do
    has_one :base_report, :as => 'reportable', :dependent => :destroy
  end
end