# frozen_string_literal: true

class Explicit::Documentation::Property
  attr_reader :name, :spec

  def initialize(name:, spec:)
    @name = name
    @spec = spec
  end
end