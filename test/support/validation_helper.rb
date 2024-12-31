# frozen_string_literal: true

module ValidationHelper
  def validate(value, spec)
    spec = ::Explicit::Spec.build(spec)

    assert_spec_render_webpage!(spec)
    assert_spec_render_swagger!(spec)
    assert_spec_jsontype!(spec)
    
    spec.validate(value)
  end

  def assert_spec_render_webpage!(spec)
    Explicit::ApplicationController.render(
      partial: spec.partial,
      locals: { spec: }
    )

    assert [true, false].include?(spec.has_details?)
  end

  def assert_spec_render_swagger!(spec)
    # TODO
  end

  def assert_spec_jsontype!(spec)
    assert spec.jsontype.present?
  end
end
