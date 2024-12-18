# frozen_string_literal: true

module Schema::Type::Default
  extend self

  def build(defaultval, schema)
    subschema = Schema::Type::Builder.build(schema)

    lambda do |value|
      value =
        if value.nil?
          defaultval.respond_to?(:call) ? defaultval.call : defaultval
        else
          value
        end

      subschema.call(value)
    end
  end
end