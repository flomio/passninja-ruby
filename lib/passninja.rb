require "net/http"
require "json"

module Passninja
  class Client
    def initialize(account_id, api_key)
      @account_id = account_id
      @api_key = api_key
    end

    def pass_templates
      PassTemplates.new(@account_id, @api_key)
    end

    def passes
      Passes.new(@account_id, @api_key)
    end
  end

  class PassTemplates
    def initialize(account_id, api_key)
      @account_id = account_id
      @api_key = api_key
    end

    def find(pass_template_key)
      uri = URI("https://api.passninja.com/v1/pass_templates/#{pass_template_key}")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@account_id, @api_key)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end
  end

  class Passes
    def initialize(account_id, api_key)
      @account_id = account_id
      @api_key = api_key
    end

    def create(pass_type, pass_data)
      required_fields = fetch_required_keys_set(pass_type)
      validate_fields(pass_data, required_fields)
      uri = URI("https://api.passninja.com/v1/passes")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@account_id, @api_key)
      request.content_type = "application/json"
      request.body = { passType: pass_type, passData: pass_data }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    def find(pass_type)
      uri = URI("https://api.passninja.com/v1/passes?passType=#{pass_type}")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@account_id, @api_key)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    def get(pass_type, serial_number)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}/#{serial_number}")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@account_id, @api_key)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    def decrypt(pass_type, payload)
      uri = URI("https://api.passninja.com/v1/passes/decrypt")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@account_id, @api_key)
      request.content_type = "application/json"
      request.body = { passType: pass_type, payload: payload }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    def update(pass_type, serial_number, pass_data)
      required_fields = fetch_required_keys_set(pass_type)
      validate_fields(pass_data, required_fields)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}/#{serial_number}")
      request = Net::HTTP::Put.new(uri)
      request.basic_auth(@account_id, @api_key)
      request.content_type = "application/json"
      request.body = { passData: pass_data }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end

    def delete(pass_type, serial_number)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}/#{serial_number}")
      request = Net::HTTP::Delete.new(uri)
      request.basic_auth(@account_id, @api_key)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)["serialNumber"]
    end

    private

    def fetch_required_keys_set(pass_type)
      uri = URI("https://api.passninja.com/v1/pass_templates/#{pass_type}/required_fields")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@account_id, @api_key)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)["required_fields"].map(&:to_sym)
    end

    def validate_fields(fields, required_fields)
      missing_fields = required_fields - fields.keys
      unless missing_fields.empty?
        raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
      end
    end
  end
end