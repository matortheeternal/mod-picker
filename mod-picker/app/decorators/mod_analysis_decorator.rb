class ModAnalysisDecorator < Decorator
  attr_accessor :mod

  def initialize(mod)
    @mod = mod
  end

  def method_missing(method_sym, *arguments, &block)
    @mod.public_send(method_sym, *arguments)
  end
end