# frozen_string_literal: true

module Schema::Type::Default
  extend self

  def build(defaultval, spec)
    subspec = Schema::Type::Composer.compose(spec)

    lambda do |value|
      value =
        if value.nil?
          defaultval.respond_to?(:call) ? defaultval.call : defaultval
        else
          value
        end

      subspec.call(value)
    end
  end
end