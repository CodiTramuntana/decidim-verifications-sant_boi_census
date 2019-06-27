# frozen_string_literal: true

require "rails"
require "decidim/core"
require "decidim/verifications"
require "virtus/multiparams"

module Decidim
  module Verifications
    module SantBoiCensus
      # This is the engine that runs on the public interface of decidim-verifications-sant_boi_census.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::SantBoiCensus

        initializer "decidim-verifications-sant_boi_census.assets" do |app|
          app.config.assets.precompile += %w(decidim-verifications-census_manifest.js decidim-verifications-census_manifest.css)
        end
      end
    end
  end
end
