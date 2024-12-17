# frozen_string_literal: true

module Schema::Type::Agreement
  extend self

  VALUES = {
    "true" => true,
    "on" => true,
    "1" => true
  }.freeze

  def build(options)
    lambda do |value|
      value =
        if value.is_a?(TrueClass)
          value
        elsif value.is_a?(::String) && options[:parse]
          VALUES[value]
        else
          nil
        end

      return [:error, :agreement] if value.nil?

      [:ok, value]
    end
  end
end
