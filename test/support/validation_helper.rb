# frozen_string_literal: true

module ValidationHelper
  def type(typespec)
    Explicit::Type.build(typespec)
  end

  def validate(value, typespec)
    type = type(typespec)

    assert_type_render_webpage!(type)
    assert_type_render_swagger!(type)

    type.validate(value)
  end

  def assert_type_render_webpage!(type)
    assert [ true, false ].include?(type.has_details?)
    assert type.summary.present?

    if type.has_details?
      Explicit::ApplicationController.render(
        partial: type.partial,
        locals: { type: }
      )
    end
  end

  def assert_type_render_swagger!(type)
    assert type.swagger_schema.is_a?(::Hash)
  end
end
