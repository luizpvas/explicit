# frozen_string_literal: true

module ValidationHelper
  def validate(value, spec)
    ::Explicit::Spec.build(spec).validate(value)
  end
end
