module Exceptions
  class ModExistsError < StandardError
    attr_accessor :mod_id, :hidden

    def initialize(mod)
      self.mod_id = mod.id
      self.hidden = mod.hidden
    end

    def message
      return "that mod has been hidden by the author or site staff." if hidden
      "that mod is already present in our database!"
    end

    def response_object
      obj = { error: message }
      obj[:mod_id] = mod_id unless hidden
      obj
    end
  end
end