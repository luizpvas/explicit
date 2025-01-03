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

    validate(file, [:file, maxsize: 2.megabytes]) => [:ok, _]

    assert_error "must be smaller than 10240 bytes", validate(file, [:file, maxsize: 10.kilobytes])
  end

  test "mime" do
    file = file_fixture_upload("this_is_fine.png", "image/png")

    validate(file, [:file, mime: %w[image/jpeg image/png]]) => [:ok, _]

    assert_error 'file mime type must be one of: ["image/jpeg", "application/pdf"]', validate(file, [:file, mime: %w[image/jpeg application/pdf]])
  end

  test "error" do
    assert_error "must be a file", validate(nil, :file)
    assert_error "must be a file", validate("foo", :file)
    assert_error "must be a file", validate("/path/to/file.png", :file)
  end
end
