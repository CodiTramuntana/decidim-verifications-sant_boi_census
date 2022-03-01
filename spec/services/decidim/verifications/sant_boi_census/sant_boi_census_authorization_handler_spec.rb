# frozen_string_literal: true

require "spec_helper"
require "digest"
require "decidim/dev/test/authorization_shared_examples"

module Decidim
  module Verifications
    module SantBoiCensus
      describe SantBoiCensusAuthorizationHandler do
        let(:subject) { handler }
        let(:handler) { described_class.from_params(params) }
        let(:document_number) { "12345678A" }
        let(:user) { create :user }
        let(:params) do
          {
            user: user,
            document_number: document_number,
            document_type: :dni
          }
        end

        it_behaves_like "an authorization handler"

        describe "metadata" do
          subject { handler.metadata }

          it "is not filled", sant_boi_census_stub_type: :valid do
            expect(subject).to eq({})
          end
        end

        describe "with a valid user" do
          context "when no document number" do
            let(:document_number) { nil }

            it { is_expected.to be_invalid }
          end

          context "with an invalid format" do
            let(:document_number) { "(╯°□°）╯︵ ┻━┻" }

            it { is_expected.to be_invalid }
          end

          context "when all data is valid", sant_boi_census_stub_type: :valid do
            it { is_expected.to be_valid }
          end

          describe "unique_id" do
            it "generates a SHA hash with 512 Bits from a given document number" do
              handler.document_number = "ABC123"
              expect(handler.unique_id).to eq("b118edbc0b58672d2ce60c9faa9261243d27ecae1e8eac1b84241824523db82f692ea3eb45ad855caeae685fff09eeb27a89f1045df1ea76e809b3fc79472cea")

              handler.document_number = "XYZ456"
              expect(handler.unique_id).to eq("27d99851d30c52729807445e634aa41cf901d6d3fa76cbb6cc0bf5df6934d5b833b1f9029edcf7aac6e122036d767af6007e7305e3376d8b0352c7e803355399")
            end
          end
        end
      end
    end
  end
end
