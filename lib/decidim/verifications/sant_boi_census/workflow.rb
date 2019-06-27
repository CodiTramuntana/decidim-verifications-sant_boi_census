# frozen_string_literal: true

Decidim::Verifications.register_workflow(:sant_boi_census_authorization_handler) do |workflow|
  workflow.form = "Decidim::Verifications::SantBoiCensus::SantBoiCensusAuthorizationHandler"
  workflow.engine = Decidim::Verifications::SantBoiCensus::Engine
end
