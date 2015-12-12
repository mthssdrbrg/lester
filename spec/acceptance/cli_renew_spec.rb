require 'spec_helper'

describe 'bin/lester renew' do
  let :command do
    Lester::Cli.new(argv, io)
  end

  let :argv do
    [
      'renew',
      '--domain', 'example.org',
      '--endpoint', 'http://127.0.0.1:4000',
      '--site-bucket', 'example-org-site',
      '--storage-bucket', 'example-org-backup',
      '--email', 'contact@example.org',
    ]
  end

  let :io do
    StringIO.new
  end

  let :private_key_path do
    File.expand_path('../../support/resources/privkey.pem', __FILE__)
  end

  let :iam do
    FakeIAM.new
  end

  let :buckets do
    {}
  end

  let :site_bucket do
    Aws::S3::Bucket.new('example-org-site')
  end

  let :storage_bucket do
    Aws::S3::Bucket.new('example-org-backup')
  end

  before do
    allow(Aws::S3::Bucket).to receive(:new) do |name, opts|
      buckets[name] ||= FakeBucket.new(name)
      buckets[name]
    end
    allow(Aws::IAM::Client).to receive(:new).and_return(iam)
  end

  before do
    storage_bucket.put_object(key: 'example.org/account/private_key.pem', body: Pathname.new(private_key_path))
  end

  describe '#run' do
    context 'with a registered private key', vcr: { cassette_name: 'new-certificate' } do
      it 'writes challenges to the expected path' do
        command.run
        key = '.well-known/acme-challenge/EGJjhjKuz9x5yNbH8IXfcZO6OljhIrwPQeTeZUcsKao'
        object = site_bucket.object(key)
        expect(object.read).to eq('EGJjhjKuz9x5yNbH8IXfcZO6OljhIrwPQeTeZUcsKao.UO9h3pHJ17bfwMzGvKlw-PSX0NpW9Dnf8xfaLhat7ac')
        key = '.well-known/acme-challenge/wdo3QEPA0D2mUav-Yx34nbNkq61bLOMjj_3obOYvE2E'
        object = site_bucket.object(key)
        expect(object.read).to eq('wdo3QEPA0D2mUav-Yx34nbNkq61bLOMjj_3obOYvE2E.UO9h3pHJ17bfwMzGvKlw-PSX0NpW9Dnf8xfaLhat7ac')
      end

      it 'uploads the new certificate' do
        command.run
        expect(iam.certificates).to_not be_empty
      end

      it 'stores the certificate' do
        command.run
        object = storage_bucket.object('example.org/certificates/201512120949/cert.pem')
        expect { OpenSSL::X509::Certificate.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate request' do
        command.run
        object = storage_bucket.object('example.org/certificates/201512120949/csr.pem')
        expect { OpenSSL::X509::Request.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate chain' do
        command.run
        object = storage_bucket.object('example.org/certificates/201512120949/chain.pem')
        expect { OpenSSL::X509::Certificate.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate fullchain' do
        command.run
        object = storage_bucket.object('example.org/certificates/201512120949/fullchain.pem')
        expect { OpenSSL::X509::Certificate.new(object.read) }.to_not raise_error
      end

      it 'stores the certificate private key' do
        command.run
        object = storage_bucket.object('example.org/certificates/201512120949/privkey.pem')
        expect { OpenSSL::PKey::RSA.new(object.read) }.to_not raise_error
      end

      it 'uses server side encryption for everything that is stored' do
        command.run
        keys = storage_bucket.keys.select { |k| k.start_with?('example.org/certificates') }
        keys.each do |key|
          object = storage_bucket.object(key)
          expect(object.options).to include(server_side_encryption: 'AES256')
        end
      end

      it 'returns 0 as exit code' do
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
            '--email', 'contact@example.org',
            '--kms-id', 'alias/letsencrypt',
          ]
        end

        it 'uses server side encryption through AWS KMS' do
          command.run
          keys = storage_bucket.keys.select { |k| k.start_with?('example.org/certificates') }
          keys.each do |key|
            object = storage_bucket.object(key)
            expect(object.options).to include(server_side_encryption: 'aws:kms')
            expect(object.options).to include(ssekms_key_id: 'alias/letsencrypt')
          end
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
        expect(io.string.chomp).to eq('No registration exists matching provided key (Acme::Error::Unauthorized)')
      end

      it 'returns a non-ok exit code' do
        code = command.run
        expect(code).to eq(1)
      end
    end
  end
end
