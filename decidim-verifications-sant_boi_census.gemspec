# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/verifications/sant_boi_census/version"

Gem::Specification.new do |s|
  s.version = Decidim::Verifications::SantBoiCensus.version
  s.authors = ["CodiTramuntana"]
  s.email = ["info@coditramuntana.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-verifications-sant_boi_census"
  s.required_ruby_version = ">= 2.5.1"

  s.name = "decidim-verifications-sant_boi_census"
  s.summary = "Decidim Verification for Sant boi Census."
  s.description = "Decidim Verification for Sant boi Census."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  DECIDIM_VERSION = "~> 0.26.5"

  s.add_dependency "decidim-core", DECIDIM_VERSION
  s.add_dependency "decidim-verifications", DECIDIM_VERSION
  s.add_dependency "rails", ">= 5.2"
  s.add_dependency "virtus-multiparams"

  s.add_development_dependency "decidim-dev", DECIDIM_VERSION
end
