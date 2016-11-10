module JsonHelpers
  def self.json_options_empty(options)
    keys = [:include, :only, :except, :methods]
    !(options.keys & keys).any?
  end
end