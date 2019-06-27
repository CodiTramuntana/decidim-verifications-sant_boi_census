# frozen_string_literal: true

module Decidim
  module Verifications
    module SantBoiCensus
      # This class holds the logic to connect to the census WS.
      class SantBoiCensusAuthorizationService
        def initialize(document_type, document_number)
          @document_type = document_type
          @document_number = document_number
          @config_values = Rails.application.secrets.sant_boi_census
        end

        # Performs the WS request, which has two methods: login and doOperationTAO.
        #
        # The login method returns a token which is needed to invoke doOperationTAO.
        # In the doOperationTAO method we make the getHabitanteByDNI request.
        #
        # Returns a Hash with the following key => values.
        #   body   => WS response body, as Nokogiri::XML instance
        #   status => WS response status, as Integer
        def perform_request
          return @response if defined?(@response)

          @token = retrieve_login_response(perform_login_request.body)
          response = perform_do_operation_tao_request

          @response = { status: response.status,
                        body: retrieve_get_habitante_by_dni_response(response.body) }
        rescue StandardError => e
          Rails.logger.error "[#{self.class.name}] Failed to perform request"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end

        private

        attr_reader :document_type, :document_number, :config_values, :token

        # Starts a session using valid credentials that allows to make requests.
        #
        # The response is a Single Sign On token to be used in further requests.
        #
        # Returns a Faraday::Response
        def perform_login_request
          Faraday.post do |request|
            request.url config_values[:sant_boi_census_url]
            request.headers["Content-Type"] = "text/xml"
            request.headers["SOAPAction"] = "login"
            request.body = login_body
          end
        end

        # Needs to inform the user and password.
        def login_body
          @login_body ||= <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gen="http://generic.services.conecta.es">
               <soapenv:Header />
               <soapenv:Body>
                  <gen:login>
                     <gen:user>#{config_values[:sant_boi_census_user]}</gen:user>
                     <gen:password>#{config_values[:sant_boi_census_password]}</gen:password>
                  </gen:login>
               </soapenv:Body>
            </soapenv:Envelope>
          XML
        end

        # Retrieves the contents of XML element 'loginResponse'.
        #
        # Returns a String
        def retrieve_login_response(string)
          Nokogiri::XML(string).remove_namespaces!.xpath("//loginResponse").text
        end

        # Makes the desired request inside doOperationTao, in our case: 'getHabitanteByDNI'.
        #
        # The response of 'getHabitanteByDNI' can be one of two things:
        # 'HABITANTE', where we can found the citizen data in 'DATOSPERSONALES'.
        # 'ERROR', where we can found the error code in 'CODE'.
        #
        # Returns a Faraday::Response
        def perform_do_operation_tao_request
          Faraday.post do |request|
            request.url config_values[:sant_boi_census_url]
            request.headers["Content-Type"] = "text/xml"
            request.headers["SOAPAction"] = "doOperationTAO"
            request.body = do_operation_tao_body
          end
        end

        # Needs to inform the token, dboid (census identification number),
        # document type and document number.
        def do_operation_tao_body
          @do_operation_tao_body ||= <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gen="http://generic.services.conecta.es">
               <soapenv:Header />
               <soapenv:Body>
                  <gen:doOperationTAO>
                     <gen:xmlIn><![CDATA[<taoServiceRequest>
                                            <application>EPOB</application>
                                            <businessName>ConectaVolanteePobBC</businessName>
                                            <operationName>getHabitanteByDNI</operationName>
                                            <data>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;
                                            &lt;PoblacionServices xmlns=&quot;http://dto.poblacion.conecta.es&quot;&gt;
                                            &lt;getHabitanteByDNI&gt;
                                            &lt;getHabitanteByDNIRequest&gt;
                                            &lt;OIDPARINS&gt;#{config_values[:sant_boi_census_dboid]}&lt;/OIDPARINS&gt;
                                            &lt;TIPODOC&gt;#{document_type}&lt;/TIPODOC&gt;
                                            &lt;IDNUMBER&gt;#{document_number}&lt;/IDNUMBER&gt;
                                            &lt;NIVEL&gt;1&lt;/NIVEL&gt;
                                            &lt;/getHabitanteByDNIRequest&gt;
                                            &lt;/getHabitanteByDNI&gt;
                                            &lt;/PoblacionServices&gt;</data>
                                            </taoServiceRequest>]]></gen:xmlIn>
                     <gen:token>#{token}</gen:token>
                  </gen:doOperationTAO>
               </soapenv:Body>
            </soapenv:Envelope>
          XML
        end

        # Retrieves the contents of XML element 'getHabitanteByDNIResponse'.
        #
        # Returns a Nokogiri::XML
        def retrieve_get_habitante_by_dni_response(string)
          xml = Nokogiri::XML(string).remove_namespaces!
          nested_xml = Nokogiri::XML(xml.xpath("//doOperationTAOResponse//doOperationTAOReturn").text)
          second_nested_xml = Nokogiri::XML(nested_xml.xpath("//taoServiceResponse/data").text).remove_namespaces!
          second_nested_xml.xpath("//PoblacionServices//getHabitanteByDNI//getHabitanteByDNIResponse")
        end
      end
    end
  end
end
