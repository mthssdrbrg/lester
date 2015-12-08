require 'pathname'

module Lester
  class PrivateKey
    def initialize(path)
      @path = path
    end

    def load
      case @path.extname
      when '.json'
        JSON::JWK.new(JSON.parse(@path.read)).to_key
      when '.pem'
        OpenSSL::PKey::RSA.new(@path.read)
      else
        raise UnknownKeyFormatError, @path
      end
    end
  end
end
