require 'spec_helper'

describe 'bin/lester renew' do
  include_context 'acceptance setup'

  let :command do
    Lester::Cli.new(argv, io)
  end

  let :argv do
    [
      'renew',
      '--domain', 'example.org',
      '--endpoint', 'http://127.0.0.1:4000',
      '--site-bucket', 'example-org-site',
      '--storage-bucket', storage_bucket_name,
      '--distribution-id', 'distribution-id',
    ]
  end

  let :storage_bucket_name do
    'example-org-backup'
  end

  before do
    storage_bucket.put_object(key: 'account/private_key.json', body: Pathname.new(private_key_path))
    cloudfront.add_config('distribution-id', {
      viewer_certificate: { iam_certificate_id: 'example.org-old' },
    })
  end

  describe '#run' do
    context 'with a registered private key', vcr: { cassette_name: 'new-certificate' } do
      it 'writes challenges to the expected path' do
        command.run
        key = '.well-known/acme-challenge/EGJjhjKuz9x5yNbH8IXfcZO6OljhIrwPQeTeZUcsKao'
        object = site_bucket.object(key)
        expect(object.read).to eq('EGJjhjKuz9x5yNbH8IXfcZO6OljhIrwPQeTeZUcsKao.XUQVUxLBe1x_yLe3HwXhatO3NImdF032T7C7BjKu6pc')
        key = '.well-known/acme-challenge/wdo3QEPA0D2mUav-Yx34nbNkq61bLOMjj_3obOYvE2E'
        object = site_bucket.object(key)
        expect(object.read).to eq('wdo3QEPA0D2mUav-Yx34nbNkq61bLOMjj_3obOYvE2E.XUQVUxLBe1x_yLe3HwXhatO3NImdF032T7C7BjKu6pc')
      end

      it 'uploads the new certificate' do
        command.run
        expect(iam.certificates).to_not be_empty
      end

      it 'installs the certificate' do
        command.run
        update = cloudfront.updates.first
        expect(update[:distribution_config][:viewer_certificate][:iam_certificate_id]).to eq('2ae9ea04d305762117cf854b39bb5ede')
      end

      it 'stores the certificate' do
        command.run
        object = storage_bucket.object('certificates/example.org/201512120949/cert.pem')
        expect { OpenSSL::X509::Certificate.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate request' do
        command.run
        object = storage_bucket.object('certificates/example.org/201512120949/csr.pem')
        expect { OpenSSL::X509::Request.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate chain' do
        command.run
        object = storage_bucket.object('certificates/example.org/201512120949/chain.pem')
        expect { OpenSSL::X509::Certificate.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate fullchain' do
        command.run
        object = storage_bucket.object('certificates/example.org/201512120949/fullchain.pem')
        expect { OpenSSL::X509::Certificate.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate private key' do
        command.run
        object = storage_bucket.object('certificates/example.org/201512120949/privkey.pem')
        expect { OpenSSL::PKey::RSA.new(object.read) }.to_not raise_error
      end

      it 'uses server side encryption for everything that is stored' do
        command.run
        keys = storage_bucket.keys.select { |k| k.start_with?('certificates/example.org') }
        expect(keys).to_not be_empty
        keys.each do |key|
          object = storage_bucket.object(key)
          expect(object.options).to include(server_side_encryption: 'AES256')
        end
      end

      it 'returns an ok exit code' do
        code = command.run
        expect(code).to eq(0)
      end

      context 'when a KMS ID is specified' do
        let :argv do
          [
            'renew',
            '--domain', 'example.org',
            '--endpoint', 'http://127.0.0.1:4000',
            '--site-bucket', 'example-org-site',
            '--storage-bucket', 'example-org-backup',
            '--distribution-id', 'distribution-id',
            '--kms-id', 'alias/letsencrypt',
          ]
        end

        it 'uses server side encryption through AWS KMS' do
          command.run
          keys = storage_bucket.keys.select { |k| k.start_with?('certificates/example.org') }
          expect(keys).to_not be_empty
          keys.each do |key|
            object = storage_bucket.object(key)
            expect(object.options).to include(server_side_encryption: 'aws:kms')
            expect(object.options).to include(ssekms_key_id: 'alias/letsencrypt')
          end
        end
      end

      context 'when --storage-bucket includes a prefix' do
        let :storage_bucket_name do
          'example-org-backup/lester'
        end

        it 'stores everything under given prefix' do
          storage_bucket.put_object(key: 'lester/account/private_key.json', body: Pathname.new(private_key_path))
          command.run
          keys = storage_bucket.keys.select { |k| k.start_with?('lester/certificates') }
          expect(keys).to_not be_empty
        end
      end
    end

    context 'when verification fails', vcr: { cassette_name: 'verification-fail' } do
      it 'prints an error message' do
        command.run
        expect(io.string).to match(/unauthorized: Invalid response/)
      end

      it 'returns a non-ok exit code' do
        command.run
        code = command.run
        expect(code).to eq(1)
      end
    end

    context 'with a non-registered private key', vcr: { cassette_name: 'new-certificate-fail' } do
      it 'prints an error message' do
        command.run
        expect(io.string.chomp).to eq('No registration exists matching provided key (Acme::Client::Error::Unauthorized)')
      end

      it 'returns a non-ok exit code' do
        code = command.run
        expect(code).to eq(1)
      end
    end
  end
end
