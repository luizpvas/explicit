# frozen_string_literal: true

module ValidationHelper
  def validate(value, spec)
    ::Schemax::Spec.build(spec).call(value)
  end
end
