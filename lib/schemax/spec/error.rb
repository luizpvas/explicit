# frozen_string_literal: true

module Schemax::Spec::Error
  extend self

  RailsI18n = ->(error, **context) do
    key = "schemax.errors.#{error}"

    ::I18n.t(key, **context)
  end

  def translate(error, translator = RailsI18n)
    case error
    in :agreement
      translator.call(:agreement)
    in [:array, index, suberr]
      translator.call(:array, index:, error: translate(suberr, translator))
    in :boolean
      translator.call(:boolean)
    in :date_time_iso8601
      translator.call(:date_time_iso8601)
    in :date_time_posix
      translator.call(:date_time_posix)
    in :hash
      translator.call(:hash)
    in [:hash_key, key, suberr]
      translator.call(:hash_key, key:, error: translate(suberr, translator))
    in [:hash_value, key, suberr]
      translator.call(:hash_value, key:, error: translate(suberr, translator))
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
    in [:literal, value]
      translator.call(:literal, value: value.inspect)
    in [:one_of, *errors]
      errors.map { translate(_1, translator) }.join(" OR ")
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
