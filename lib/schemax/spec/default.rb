# frozen_string_literal: true

module Schemax::Spec::Default
  extend self

  def build(defaultval, subspec)
    subspec_validator = Schemax::Spec::build(subspec)

    lambda do |value|
      value =
        if value.nil?
          defaultval.respond_to?(:call) ? defaultval.call : defaultval
        else
          value
        end

      subspec_validator.call(value)
    end
  end
end