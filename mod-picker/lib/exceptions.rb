module Exceptions
  class ModExistsError < StandardError
    attr_accessor :mod_id

    def initialize(mod_id)
      self.mod_id = mod_id
    end

    def message
      "that mod is already present in our database!"
    end
  end
end