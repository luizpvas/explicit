require_relative "lib/explicit/version"

Gem::Specification.new do |spec|
  spec.name        = "explicit"
  spec.version     = Explicit::VERSION
  spec.authors     = ["Luiz Vasconcellos"]
  spec.email       = ["luizpvasc@gmail.com"]
  spec.homepage    = "https://github.com/luizpvas/explicit"
  spec.summary     = "Explicit is a validation and documentation library for JSON APIs"
  spec.description = "Explicit is a validation and documentation library for JSON APIs that enforces documented specs during runtime."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.1"
end
