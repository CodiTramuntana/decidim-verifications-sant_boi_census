# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :system, perform_enqueued: true, with_authorization_workflows: ["sant_boi_census_authorization_handler"] do
  let(:organization) do
    create(
      :organization,
      default_locale: :ca,
      available_locales: [:ca, :es], # Sant Boi supported locales
      available_authorizations: ["sant_boi_census_authorization_handler"]
    )
  end

  let(:valid_document_number) { "12345678A" }

  before do
    switch_to_host(organization.host)
  end

  context "when the user is logged in" do
    let(:user) { create(:user, :confirmed, organization: organization) }

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "allows the user to authorize against available authorizations", sant_boi_census_stub_type: :valid do
      within_user_menu do
        click_link "El meu compte"
      end

      click_link "Autoritzacions"
      click_link "Ciutadà de Sant Boi"

      submit_sant_boi_census_form(valid_document_number)

      expect(page).to have_content("Has estat autoritzada amb correctament.") # Wrong translation from decidim

      visit decidim_verifications.authorizations_path

      within ".authorizations-list" do
        expect(page).to have_content("Ciutadà de Sant Boi")
        expect(page).not_to have_link("Ciutadà de Sant Boi")
      end
    end

    context "when the user has already been authorised" do
      let!(:authorization) do
        create(:authorization,
               name: Decidim::Verifications::SantBoiCensus::SantBoiCensusAuthorizationHandler.handler_name,
               user: user)
      end

      it "shows the authorization at their account" do
        visit decidim_verifications.authorizations_path

        within ".authorizations-list" do
          expect(page).to have_content("Ciutadà de Sant Boi")
          expect(page).not_to have_link("Ciutadà de Sant Boi")
          expect(page).to have_content(I18n.localize(authorization.granted_at, format: :long, locale: :ca))
        end
      end
    end

    context "when data is not valid" do
      before do
        visit decidim_verifications.new_authorization_path(handler: "sant_boi_census_authorization_handler")
      end

      it "shows an error if document FORMAT is not valid" do
        submit_sant_boi_census_form("(╯°□°）╯︵ ┻━┻")

        expect(page).to have_content("S'ha produït un error en crear l'autorització.")
        within "label[for='authorization_handler_document_number']" do
          expect(page).to have_css(".form-error.is-visible")
        end
      end

      it "shows an error when the document NUMBER is not valid", sant_boi_census_stub_type: :invalid_document do
        submit_sant_boi_census_form(valid_document_number)

        expect(page).to have_content("S'ha produït un error en crear l'autorització.")
        expect(page).to have_content("El document d'identitat no és vàlid")
      end

      it "shows an error when the citizen AGE is not valid", sant_boi_census_stub_type: :invalid_age do
        submit_sant_boi_census_form(valid_document_number)

        expect(page).to have_content("S'ha produït un error en crear l'autorització.")
        expect(page).to have_content("Heu de tenir almenys 16 anys")
      end

      it "does not submit when data is not fulfilled" do
        submit_sant_boi_census_form("")

        expect(page).to have_content("Hi ha un error en aquest camp")
      end
    end

    private

    def submit_sant_boi_census_form(document_number)
      within "#new_authorization_handler" do
        select "DNI", from: :authorization_handler_document_type
        fill_in "authorization_handler_document_number", with: document_number

        find('button[type="submit"]').click
      end
    end
  end
end
