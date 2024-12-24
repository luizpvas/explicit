require_relative "lib/schemax/version"

Gem::Specification.new do |spec|
  spec.name        = "schemax"
  spec.version     = Schemax::VERSION
  spec.authors     = ["Luiz Vasconcellos"]
  spec.email       = ["luizpvasc@gmail.com"]
  spec.homepage    = "https://github.com/luizpvas/schemax"
  spec.summary     = "schema-api is a documentation and validation library for JSON APIs"
  spec.description = "schema-api allows you to document, test and specify requests and responses schemas"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.1"
end
