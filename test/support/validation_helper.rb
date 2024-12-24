# frozen_string_literal: true

module ValidationHelper
  def validate(value, spec)
    result = ::Schemax::Spec.build(spec).call(value)

    ensure_error_has_translation!(result)

    result
  end

  private
    def ensure_error_has_translation!(result)
      case result
      in [:ok, value] then :all_good
      in [:error, err] then Schemax::Spec::Error.translate(err)
      end
    end
end
