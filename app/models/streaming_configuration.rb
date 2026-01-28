require 'resolv'

class StreamingConfiguration < ApplicationRecord
    # Validações
    validates :server_ip, presence: true, format: { with: Resolv::IPv4::Regex, message: "deve ser um IP válido" }
    validates :port, numericality: { only_integer: true, greater_than: 0, less_than: 65536 }
  
    # Métodos adicionais
    def connection_url
      "http://#{server_ip}:#{port}"
    end
  end
  