require 'spec_helper'

module Lester
  describe Uploader do
    let :uploader do
      described_class.new(iam)
    end

    let :iam do
      double(:iam)
    end

    let :certificate_name do
      'name'
    end

    let :certificate do
      double(:certificate)
    end

    let :private_key do
      double(:private_key)
    end

    before do
      allow(iam).to receive(:upload_server_certificate)
      allow(certificate).to receive(:to_pem).and_return('PEM ENCODED CERTIFICATE')
      allow(certificate).to receive(:chain_to_pem).and_return('PEM ENCODED CHAIN')
      allow(private_key).to receive(:to_pem).and_return('PEM ENCODED KEY')
    end

    describe '#upload' do
      before do
        uploader.upload(certificate_name, certificate, private_key)
      end

      it 'uploads the certificate to IAM' do
        expect(iam).to have_received(:upload_server_certificate)
      end

      it 'uses `/cloudfront/` as path argument' do
        expect(iam).to have_received(:upload_server_certificate).with(hash_including(path: '/cloudfront/'))
      end

      it 'uses given name for the certificate' do
        expect(iam).to have_received(:upload_server_certificate).with(hash_including(server_certificate_name: 'name'))
      end

      it 'uses a PEM encoded certificate' do
        expect(iam).to have_received(:upload_server_certificate).with(hash_including(certificate_body: 'PEM ENCODED CERTIFICATE'))
      end

      it 'uses a PEM encoded private key' do
        expect(iam).to have_received(:upload_server_certificate).with(hash_including(private_key: 'PEM ENCODED KEY'))
      end

      it 'uses a PEM encoded certificate chain' do
        expect(iam).to have_received(:upload_server_certificate).with(hash_including(certificate_chain: 'PEM ENCODED CHAIN'))
      end
    end
  end
end
