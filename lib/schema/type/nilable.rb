# frozen_string_literal: true

module Schema::Type::Nilable
  extend self

  def build(spec)
    subspec = Schema::Type::Composer.compose(spec)

    lambda do |value|
      return [:ok, nil] if value.nil?

      subspec.call(value)
    end
  end
end
