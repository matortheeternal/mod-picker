module BetterJson
  extend ActiveSupport::Concern

  # noinspection RubySuperCallWithoutSuperclassInspection
  def as_json(options={})
    if options[:format]
      super(public_send("#{options[:format]}_json_format"))
    elsif self.class.json_options_empty(options)
      super(options.merge(self.class.base_json_format))
    else
      super(options)
    end
  end

  module ClassMethods
    # STUB
    def base_json_format
      {}
    end

    def json_options_empty(options)
      keys = [:include, :only, :except, :methods]
      !(options.keys & keys).any?
    end
  end
end