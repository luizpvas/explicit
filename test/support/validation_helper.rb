# frozen_string_literal: true

module ValidationHelper
  def validate(value, spec_name)
    ::Schema::Type::Composer.compose(spec_name).call(value)
  end
end
