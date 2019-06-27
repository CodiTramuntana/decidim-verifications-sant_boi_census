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
              expect(handler.unique_id).to eq("fa4e5aadfb9b9ac188bae18de2dbc3c9ef3c4729b77ab887788fe3cb6b42d19620ca601758e36de0b304b2f07b07a3b7d07b17887043d785ab24494cbf52d8e6")

              handler.document_number = "XYZ456"
              expect(handler.unique_id).to eq("9676e0ce31ec417e9d22ee0f61d814d42b9f67ced2cdf0bf0f90ea0ad3b1ce737d75c87034463f148db08b9d8ac8e6d5a0532fac94ccd0d823c914a7ca020c53")
            end
          end
        end
      end
    end
  end
end
