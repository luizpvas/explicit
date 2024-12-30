# frozen_string_literal: true

module ValidationHelper
  def validate(value, spec)
    result = ::Explicit::Spec.build(spec).validate(value)

    ensure_error_has_translation!(result)

    result
  end

  private
    def ensure_error_has_translation!(result)
      case result
      in [:ok, value] then :all_good
      in [:error, err] then Explicit::Spec::Error.translate(err)
      end
    end
end
