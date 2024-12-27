require "explicit/configuration"
require "explicit/documentation"
require "explicit/engine"
require "explicit/test_helper"
require "explicit/version"

require "explicit/request"
require "explicit/request/example"
require "explicit/request/example/recorder"
require "explicit/request/invalid_params"
require "explicit/request/invalid_response_error"
require "explicit/request/response"
require "explicit/request/route"

require "explicit/spec"
require "explicit/spec/agreement"
require "explicit/spec/array"
require "explicit/spec/boolean"
require "explicit/spec/date_time_iso8601"
require "explicit/spec/date_time_posix"
require "explicit/spec/default"
require "explicit/spec/error"
require "explicit/spec/hash"
require "explicit/spec/inclusion"
require "explicit/spec/integer"
require "explicit/spec/literal"
require "explicit/spec/nilable"
require "explicit/spec/one_of"
require "explicit/spec/record"
require "explicit/spec/string"

module Explicit
  extend self

  attr_reader :configuration
  @configuration = Configuration.new

  def configure(&block)
    block.call(@configuration)
  end
end
