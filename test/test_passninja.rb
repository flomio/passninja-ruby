require "minitest/autorun"
require_relative "../lib/passninja"
require "webmock/minitest"

class TestPassninja < Minitest::Test
  def setup
    @client = Passninja::Client.new("account_id", "api_key")
  end

  def test_pass_templates_find
    stub_request(:get, "https://api.passninja.com/v1/pass_templates/ptk_0x14")
      .to_return(body: { pass_type_id: "ptk_0x14" }.to_json, headers: { 'Content-Type' => 'application/json' })

    pass_template = @client.pass_templates.find("ptk_0x14")
    assert_equal "ptk_0x14", pass_template["pass_type_id"]
  end

  def test_passes_create
    stub_request(:get, "https://api.passninja.com/v1/pass_templates/ptk_0x14/required_fields")
      .to_return(status: 200, body: { required_fields: ["discount", "memberName"] }.to_json, headers: { 'Content-Type' => 'application/json' })

    stub_request(:post, "https://api.passninja.com/v1/passes")
      .to_return(body: { url: "http://example.com", passType: "ptk_0x14", serialNumber: "12345" }.to_json, headers: { 'Content-Type' => 'application/json' })

    pass = @client.passes.create("ptk_0x14", { discount: "50%", memberName: "John" })
    assert_equal "http://example.com", pass["url"]
    assert_equal "ptk_0x14", pass["passType"]
    assert_equal "12345", pass["serialNumber"]
  end

  def test_passes_find
    stub_request(:get, "https://api.passninja.com/v1/passes?passType=ptk_0x14")
      .to_return(body: [{ serialNumber: "12345" }].to_json, headers: { 'Content-Type' => 'application/json' })

    passes = @client.passes.find("ptk_0x14")
    assert_equal "12345", passes.first["serialNumber"]
  end

  def test_passes_get
    stub_request(:get, "https://api.passninja.com/v1/passes/ptk_0x14/12345")
      .to_return(body: { serialNumber: "12345" }.to_json, headers: { 'Content-Type' => 'application/json' })

    pass = @client.passes.get("ptk_0x14", "12345")
    assert_equal "12345", pass["serialNumber"]
  end

  def test_passes_decrypt
    stub_request(:post, "https://api.passninja.com/v1/passes/decrypt")
      .to_return(body: { decrypted: "data" }.to_json, headers: { 'Content-Type' => 'application/json' })

    decrypted_pass = @client.passes.decrypt("ptk_0x14", "encrypted_payload")
    assert_equal "data", decrypted_pass["decrypted"]
  end

  def test_passes_update
    stub_request(:get, "https://api.passninja.com/v1/pass_templates/ptk_0x14/required_fields")
      .to_return(status: 200, body: { required_fields: ["discount", "memberName"] }.to_json, headers: { 'Content-Type' => 'application/json' })

    stub_request(:put, "https://api.passninja.com/v1/passes/ptk_0x14/12345")
      .to_return(body: { serialNumber: "12345" }.to_json, headers: { 'Content-Type' => 'application/json' })

    updated_pass = @client.passes.update("ptk_0x14", "12345", { discount: "100%", memberName: "Ted" })
    assert_equal "12345", updated_pass["serialNumber"]
  end

  def test_passes_delete
    stub_request(:delete, "https://api.passninja.com/v1/passes/ptk_0x14/12345")
      .to_return(body: { serialNumber: "12345" }.to_json, headers: { 'Content-Type' => 'application/json' })

    deleted_serial_number = @client.passes.delete("ptk_0x14", "12345")
    assert_equal "12345", deleted_serial_number
  end
end
