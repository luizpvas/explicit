# frozen_string_literal: true

module Schema::Type::Nilable
  extend self

  def build(schema)
    subschema = Schema::Type::Builder.build(schema)

    lambda do |value|
      return [:ok, nil] if value.nil?

      subschema.call(value)
    end
  end
end
