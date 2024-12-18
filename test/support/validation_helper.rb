# frozen_string_literal: true

module ValidationHelper
  def validate(value, schema)
    ::Schema::Type::Builder.build(schema).call(value)
  end
end
