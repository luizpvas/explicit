# frozen_string_literal: true

module Explicit::Spec::Array
  extend self

  def build(itemspec, options)
    itemspec_validator = Explicit::Spec.build(itemspec)

    lambda do |values|
      return [:error, :array] if !values.is_a?(::Array)

      if options[:empty] == false && values.empty?
        return [:error, :empty]
      end

      validated = []

      values.each.with_index do |value, index|
        case itemspec_validator.call(value)
        in [:ok, value]  then validated << value
        in [:error, err] then return [:error, [:array, index, err]]
        end
      end

      [:ok, validated]
    end
  end
end
