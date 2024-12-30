# frozen_string_literal: true

class Explicit::Spec::String < Explicit::Spec
  attr_reader :empty, :strip, :format, :minlength, :maxlength

  def initialize(empty: nil, strip: nil, format: nil, minlength: nil, maxlength: nil)
    @empty = empty
    @strip = strip
    @format = format
    @minlength = minlength
    @maxlength = maxlength
  end

  def call(value)
    return [:error, :string] if !value.is_a?(::String)

    value = value.strip if strip

    if empty == false && value.empty?
      return [:error, :empty]
    end

    if minlength && value.length < minlength
      return [:error, [:minlength, minlength:]]
    end

    if maxlength && value.length > maxlength
      return [:error, [:maxlength, maxlength:]]
    end

    if format && !format.match?(value)
      return [:error, [:format, format]]
    end

    [:ok, value]
  end
end