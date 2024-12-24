# frozen_string_literal: true

module Schemax::Spec::Error
  extend self

  RailsI18n = ->(error, **context) do
    key = "schema.errors.#{error}"

    ::I18n.t(key, **context)
  end

  def translate(error, translator = RailsI18n)
    case error
    in :agreement
      translator.call(:agreement)
    in [:array, index, suberr]
      translator.call(:array, index:, error: translator.call(suberr))
    in :boolean
      translator.call(:boolean)
    in :date_time_iso8601
      translator.call(:date_time_iso8601)
    in :date_time_posix
      translator.call(:date_time_posix)
    in [:inclusion, values]
      translator.call(:inclusion, values: values.inspect)
    in :integer
      translator.call(:integer)
    in [:min, min]
      translator.call(:min, min:)
    in [:max, max]
      translator.call(:max, max:)
    in :negative
      translator.call(:negative)
    in :positive
      translator.call(:positive)
    in :string
      translator.call(:string)
    in :empty
      translator.call(:empty)
    in [:minlength, minlength]
      translator.call(:minlength, minlength:)
    in [:maxlength, maxlength]
      translator.call(:maxlength, maxlength:)
    in [:format, regex]
      translator.call(:format, regex: regex.inspect)
    in Hash
      error.to_h { |attr_name, err| [attr_name, translate(err, translator)] }
    end
  end
end
