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
      end
    end
  end
end
