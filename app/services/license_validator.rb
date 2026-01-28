require 'net/http'
require 'json'
require 'base64'

class LicenseValidator
  GITHUB_LICENSE_URL = 'https://raw.githubusercontent.com/AtanaelVmax22/SoftexTV/refs/heads/main/license.json'

  def self.valid?
    token = ENV["LICENSE_TOKEN"] || stored_token
    return false unless token

    json = fetch_license_data
    return false unless json

    license = json["licenses"].find { |lic| decode(lic["token"]) == token }
    return false unless license

    Date.parse(license["valid_until"]) >= Date.today
  rescue => e
    Rails.logger.error "Erro de validação de licença: #{e.message}"
    false
  end

  def self.valid_token?(token)
    json = fetch_license_data
    return false unless json

    json["licenses"].any? { |lic| decode(lic["token"]) == token }
  end

  def self.decode(token_base64)
    Base64.decode64(token_base64.to_s.strip)
  end

  def self.fetch_license_data
    uri = URI(GITHUB_LICENSE_URL)
    response = Net::HTTP.get_response(uri)
  
    return nil unless response.is_a?(Net::HTTPSuccess)
  
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "Erro ao buscar dados da licença: #{e.message}"
    nil
  end
  

  def self.stored_token
    path = Rails.root.join('.license_token')
    File.exist?(path) ? File.read(path).strip : nil
  end

  def self.store_token(token)
    path = Rails.root.join('.license_token')
    File.write(path, token)
  end
end
