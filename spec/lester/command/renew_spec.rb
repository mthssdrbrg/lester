require 'spec_helper'

module Lester
  module Command
    describe Renew do
      let :command do
        described_class.new(domain, acme_client, authenticator, uploader, store, options)
      end

      let :domain do
        'example.org'
      end

      let :acme_client do
        double(:acme_client)
      end

      let :authenticator do
        double(:authenticator)
      end

      let :uploader do
        double(:uploader)
      end

      let :store do
        double(:store)
      end

      let :options do
        {
          key_class: key_impl,
          csr_class: csr_impl,
        }
      end

      let :key_impl do
        double(new: private_key)
      end

      let :csr_impl do
        double(:csr_impl)
      end

      let :authorization do
        double(:authorization)
      end

      let :http01_challenge do
        double(:challenge)
      end

      let :certificate do
        OpenSSL::X509::Certificate.new.tap do |cert|
          cert.not_before = Time.utc(2016, 1, 1)
        end
      end

      let :chain do
        2.times.map { OpenSSL::X509::Certificate.new }
      end

      let :private_key do
        OpenSSL::PKey::RSA.new(2048)
      end

      let :new_certificate do
        Acme::Client::Certificate.new(certificate, chain, nil)
      end

      before do
        allow(acme_client).to receive(:authorize).and_return(authorization)
        allow(acme_client).to receive(:new_certificate).and_return(new_certificate)
        allow(authorization).to receive(:http01).and_return(http01_challenge)
        allow(authenticator).to receive(:authenticate).with(http01_challenge)
        allow(uploader).to receive(:upload)
        allow(csr_impl).to receive(:new) do |args|
          Acme::Client::CertificateRequest.new(args)
        end
        allow(store).to receive(:put)
      end

      describe '#run' do
        before do
          command.run
        end

        it 'authorizes using the ACME client' do
          expect(acme_client).to have_received(:authorize).with(domain: 'example.org')
          expect(acme_client).to have_received(:authorize).with(domain: 'www.example.org')
        end

        it 'requests a new certificate' do
          expect(acme_client).to have_received(:new_certificate)
        end

        it 'uploads the new certificate with a timestamp suffix' do
          expect(uploader).to have_received(:upload).with('example.org-201601010000', new_certificate, private_key)
        end

        it 'stores the certificate under a timestamp prefix' do
          expect(store).to have_received(:put).with('201601010000/cert.pem', certificate.to_pem)
        end

        it 'stores the certificate request under a timestamp prefix' do
          expect(store).to have_received(:put).with('201601010000/csr.pem', anything)
        end

        it 'stores the certificate chain under a timestamp prefix' do
          expect(store).to have_received(:put).with('201601010000/chain.pem', chain.map(&:to_pem).join)
        end

        it 'stores the certificate fullchain under a timestamp prefix' do
          expect(store).to have_received(:put).with('201601010000/fullchain.pem', certificate.to_pem + chain.map(&:to_pem).join)
        end

        it 'stores the certificate private key under a timestamp prefix' do
          expect(store).to have_received(:put).with('201601010000/privkey.pem', private_key.to_pem)
        end
      end
    end
  end
end
