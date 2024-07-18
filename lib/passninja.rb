require "net/http"
require "json"

module PassNinja
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
      puts uri
      request = Net::HTTP::Get.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "Unable to parse response" }
      end
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
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id
      request.content_type = "application/json"
      request.body = { passType: pass_type, pass: pass_data }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "Unable to parse response" }
      end
    end

    def find(pass_type)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}")
      request = Net::HTTP::Get.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "Unable to parse response" }
      end
    end

    def get(pass_type, serial_number)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}/#{serial_number}")
      request = Net::HTTP::Get.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "Unable to parse response. Server response code: #{response.code}" }
      end
    end

    def decrypt(pass_type, payload)
      uri = URI("https://api.passninja.com/v1/passes/decrypt")
      request = Net::HTTP::Post.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id
      request.content_type = "application/json"
      request.body = { passType: pass_type, payload: payload }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "Unable to parse response" }
      end
    end

    def update(pass_type, serial_number, pass_data)
      required_fields = fetch_required_keys_set(pass_type)
      validate_fields(pass_data, required_fields)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}/#{serial_number}")
      request = Net::HTTP::Put.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id
      request.content_type = "application/json"
      request.body = { passData: pass_data }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "Unable to parse response" }
      end
    end

    def delete(pass_type, serial_number)
      uri = URI("https://api.passninja.com/v1/passes/#{pass_type}/#{serial_number}")
      request = Net::HTTP::Delete.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)["serialNumber"]
    end

    private

    def fetch_required_keys_set(pass_type)
      uri = URI("https://api.passninja.com/v1/passtypes/keys/#{pass_type}")

      request = Net::HTTP::Get.new(uri)
      request["X-API-KEY"] = @api_key
      request["X-ACCOUNT-ID"] = @account_id

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)["keys"]
    end

    def validate_fields(fields, required_fields)
      missing_fields = required_fields.map(&:to_sym) - fields.keys.map(&:to_sym)
      unless missing_fields.empty?
        raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
      end
    end
  end
end