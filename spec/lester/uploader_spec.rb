require 'spec_helper'

module Lester
  describe Uploader do
    let :uploader do
      described_class.new(iam, cloudfront, distribution_id)
    end

    let :iam do
      double(:iam)
    end

    let :cloudfront do
      double(:cloudfront)
    end

    let :distribution_id do
      'distribution-id'
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

    let :iam_response do
      double(:iam_response)
    end

    let :distribution_config do
      {
        viewer_certificate: {
          iam_certificate_id: 'old-certificate-id',
          some: 'other-option',
        },
        top_level_key: {
          hello: :world,
        }
      }
    end

    before do
      allow(iam_response).to receive(:server_certificate_metadata) do
        double(certificate_id: 'certificate-id')
      end
      allow(iam).to receive(:upload_server_certificate).and_return(iam_response)
      allow(certificate).to receive(:to_pem).and_return('PEM ENCODED CERTIFICATE')
      allow(certificate).to receive(:chain_to_pem).and_return('PEM ENCODED CHAIN')
      allow(private_key).to receive(:to_pem).and_return('PEM ENCODED KEY')
      allow(cloudfront).to receive(:get_distribution_config) do
        double(distribution_config: distribution_config, etag: 'ETAG')
      end
      allow(cloudfront).to receive(:update_distribution)
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

      it 'fetches distribution config for the given distribution ID' do
        expect(cloudfront).to have_received(:get_distribution_config).with(id: 'distribution-id')
      end

      it 'updates the IAM certificate ID' do
        expect(cloudfront).to have_received(:update_distribution) do |args|
          expect(args[:distribution_config][:viewer_certificate][:iam_certificate_id]).to eq('certificate-id')
        end
      end

      it 'leaves all other configuration untouched' do
        distribution_config[:viewer_certificate].delete(:iam_certificate_id)
        expect(cloudfront).to have_received(:update_distribution).with(hash_including(distribution_config: hash_including(distribution_config)))
      end

      it 'includes etag from distribution config response when updating distribution' do
        expect(cloudfront).to have_received(:update_distribution).with(hash_including(if_match: 'ETAG'))
      end

      it 'uses given distribution ID when updating distribution' do
        expect(cloudfront).to have_received(:update_distribution).with(hash_including(id: 'distribution-id'))
      end
    end
  end
end
