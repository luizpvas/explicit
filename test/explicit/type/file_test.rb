# frozen_string_literal: true

require "test_helper"

class Explicit::Type::FileTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "ok" do
    file = file_fixture_upload("this_is_fine.png", "image/png")

    validate(file, :file) => [:ok, _]

    assert_instance_of Rack::Test::UploadedFile, file
  end

  test "maxsize" do
    file = file_fixture_upload("this_is_fine.png", "image/png")

    validate(file, [:file, max_size: 2.megabytes]) => [:ok, _]

    assert_error "must be smaller than 10240 bytes", validate(file, [:file, max_size: 10.kilobytes])
  end

  test "content_types" do
    file = file_fixture_upload("this_is_fine.png", "image/png")

    validate(file, [:file, content_types: %w[image/jpeg image/png]]) => [:ok, _]

    assert_error(
      'file content type must be one of: ["image/jpeg", "application/pdf"]',
      validate(file, [:file, content_types: %w[image/jpeg application/pdf]])
    )
  end

  test "error" do
    assert_error "must be a file", validate(nil, :file)
    assert_error "must be a file", validate("foo", :file)
    assert_error "must be a file", validate("/path/to/file.png", :file)
  end
end
