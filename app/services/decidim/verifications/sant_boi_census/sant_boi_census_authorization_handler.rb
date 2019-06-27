# frozen_string_literal: true

require "digest"

module Decidim
  module Verifications
    module SantBoiCensus
      # Checks the authorization against the census of Sant Boi.
      class SantBoiCensusAuthorizationHandler < Decidim::AuthorizationHandler
        DOCUMENT_TYPES = %w(dni nie passport).freeze

        attribute :document_number, String
        attribute :document_type, String

        validates :document_type,
                  inclusion: { in: DOCUMENT_TYPES },
                  presence: true

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validate :ws_request_must_succeed
        validate :document_must_be_valid
        validate :citizen_must_be_over_16_years_of_age

        def document_types_for_select
          DOCUMENT_TYPES.map { |type| [I18n.t(type, scope: "decidim.verifications.id_documents"), type] }
        end

        def unique_id
          Digest::SHA512.hexdigest(
            "#{document_number}-#{Rails.application.secrets.secret_key_base}"
          )
        end

        private

        # Validates the request status is: OK 200.
        def ws_request_must_succeed
          return if errors.any?

          @response = perform_request

          errors.add(:base, I18n.t("connection_failed", scope: "errors.messages.sant_boi_census_authorization_handler")) unless @response[:status] == 200
        end

        # Validates the document against the Sant Boi WS.
        def document_must_be_valid
          return if errors.any? || citizen_found?

          case error_code
          when "0037" # No existe ningun habitante con los datos introducidos.
            errors.add(:document_number, I18n.t("document_number_not_valid", scope: "errors.messages.sant_boi_census_authorization_handler"))
          else
            Rails.logger.info "[#{self.class.name}] Unexpected WS response\n#{@response[:body]}"
            errors.add(:base, I18n.t("unexpected_error", scope: "errors.messages.sant_boi_census_authorization_handler"))
          end
        end

        # Validates citizen is over 16 years of age.
        def citizen_must_be_over_16_years_of_age
          return if errors.any? || over_16_years_of_age?

          errors.add(:base, I18n.t("too_young", scope: "errors.messages.sant_boi_census_authorization_handler"))
        end

        # Document type paramater, as String.
        def sanitized_document_type
          case document_type&.to_sym
          when :dni
            "01"
          when :passport
            "02"
          when :nie
            "03"
          end
        end

        # Returns a Hash with the following key => values.
        #   body   => WS response body, as Nokogiri::XML instance
        #   status => WS response status, as Integer
        def perform_request
          SantBoiCensusAuthorizationService.new(sanitized_document_type, document_number).perform_request
        end

        # Returns true or false depending on whether XML element 'HABITANTE' is found.
        def citizen_found?
          @response[:body].xpath("//HABITANTE").present?
        end

        # Retrieves the error code.
        #
        # Returns a String.
        def error_code
          @response[:body].xpath("//ERROR//CODE").text
        end

        # Returns true or false
        def over_16_years_of_age?
          date_string = @response[:body].xpath("//HABITANTE//DATOSPERSONALES//HABFECNAC").text
          date_of_birth = Date.parse(date_string)
          age = ((Time.zone.now - date_of_birth.to_datetime) / 1.year.seconds).floor
          age >= 16
        end
      end
    end
  end
end
