require 'spec_helper'

module Lester
  describe PrivateKey do
    let :private_key do
      described_class.new(Pathname.new(path))
    end

    describe '.load' do
      context 'with a PEM encoded key' do
        let :path do
          File.expand_path('../../support/resources/privkey.pem', __FILE__)
        end

        it 'loads the key' do
          expect(private_key.load).to be_a(OpenSSL::PKey::RSA)
        end
      end

      context 'with a JWK encoded key' do
        let :path do
          File.expand_path('../../support/resources/privkey.json', __FILE__)
        end

        it 'loads the key' do
          expect(private_key.load).to be_a(OpenSSL::PKey::RSA)
        end
      end

      context 'with any other key type' do
        let :path do
          File.expand_path('../../support/resources/privkey.txt')
        end

        it 'raises an error' do
          expect { private_key.load }.to raise_error(UnknownKeyFormatError)
        end
      end
    end
  end
end
