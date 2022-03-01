# frozen_string_literal: true

module SantBoiCensusAuthorizationHandlerStubs
  def stub_valid_login_request
    stub_request(:post, sant_boi_census_url)
      .with(
        body: File.read(File.dirname(__FILE__) + "/fixtures/login_valid_request.xml"),
        headers: headers("login")
      ).to_return(
        status: 200,
        body: File.read(File.dirname(__FILE__) + "/fixtures/login_valid_response.xml"),
        headers: {}
      )
  end

  def stub_valid_do_operation_tao_request
    stub_request(:post, sant_boi_census_url)
      .with(
        body: File.read(File.dirname(__FILE__) + "/fixtures/doOperationTAO_valid_request.xml"),
        headers: headers("doOperationTAO")
      ).to_return(
        status: 200,
        body: File.read(File.dirname(__FILE__) + "/fixtures/doOperationTAO_valid_response.xml"),
        headers: {}
      )
  end

  def stub_invalid_do_operation_tao_request_document_error
    stub_request(:post, sant_boi_census_url)
      .with(
        body: File.read(File.dirname(__FILE__) + "/fixtures/doOperationTAO_valid_request.xml"),
        headers: headers("doOperationTAO")
      ).to_return(
        status: 200,
        body: File.read(File.dirname(__FILE__) + "/fixtures/doOperationTAO_invalid_response_document_error.xml"),
        headers: {}
      )
  end

  # Inside '/fixtures/doOperationTAO_invalid_response_age_error.xml'
  # the value of 'HABFECNAC' element must return an age less than 16 years.
  def stub_invalid_do_operation_tao_request_age_error
    stub_request(:post, sant_boi_census_url)
      .with(
        body: File.read(File.dirname(__FILE__) + "/fixtures/doOperationTAO_valid_request.xml"),
        headers: headers("doOperationTAO")
      ).to_return(
        status: 200,
        body: File.read(File.dirname(__FILE__) + "/fixtures/doOperationTAO_invalid_response_age_error.xml"),
        headers: {}
      )
  end

  private

  def sant_boi_census_url
    Rails.application.secrets.sant_boi_census[:sant_boi_census_url]
  end

  def headers(soap_action)
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Content-Type" => "text/xml",
      "Soapaction" => soap_action,
      "User-Agent" => "Faraday v2.2.0"
    }
  end
end

RSpec.configure do |config|
  config.before sant_boi_census_stub_type: :valid do
    stub_valid_login_request
    stub_valid_do_operation_tao_request
  end

  config.before sant_boi_census_stub_type: :invalid_document do
    stub_valid_login_request
    stub_invalid_do_operation_tao_request_document_error
  end

  config.before sant_boi_census_stub_type: :invalid_age do
    stub_valid_login_request
    stub_invalid_do_operation_tao_request_age_error
  end
end
