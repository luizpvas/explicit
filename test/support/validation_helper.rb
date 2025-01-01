# frozen_string_literal: true

module ValidationHelper
  def validate(value, type)
    type = ::Explicit::Type.build(type)

    assert_type_render_webpage!(type)
    assert_type_render_swagger!(type)
    assert_jsontype!(type)
    
    type.validate(value)
  end

  def assert_type_render_webpage!(type)
    Explicit::ApplicationController.render(
      partial: type.partial,
      locals: { type: }
    )

    assert [true, false].include?(type.has_details?)
  end

  def assert_type_render_swagger!(type)
    # TODO
  end

  def assert_jsontype!(type)
    assert type.jsontype.present?
  end
end
