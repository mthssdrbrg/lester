require 'spec_helper'

describe 'bin/lester init' do
  let :command do
    Lester::Cli.new(argv, io)
  end

  let :argv do
    [
      'init',
      '--domain', 'example.org',
      '--storage-bucket', 'example-org-backup',
      '--private-key', private_key_path,
    ]
  end

  let :private_key_path do
    File.expand_path('../../support/resources/privkey.pem', __FILE__)
  end

  let :io do
    StringIO.new
  end

  let :storage_bucket do
    Aws::S3::Bucket.new('example-org-backup')
  end

  let :buckets do
    {}
  end

  before do
    allow(Aws::S3::Bucket).to receive(:new) do |name, opts|
      buckets[name] ||= FakeBucket.new(name)
      buckets[name]
    end
  end

  context 'when the private key exists' do
    it 'stores it' do
      command.run
      object = storage_bucket.object('example.org/account/private_key.pem')
      expect { OpenSSL::PKey::RSA.new(object.read) }.to_not raise_error
    end

    it 'returns an ok exit code' do
      code = command.run
      expect(code).to eq(0)
    end
  end

  context 'when the private key does not exist' do
    let :private_key_path do
      'this/should/not/exist.pem'
    end

    it 'prints an error message' do
      command.run
      expect(io.string).to match(/No such file or directory/)
    end

    it 'returns a non-ok exit code' do
      code = command.run
      expect(code).to eq(1)
    end
  end
end
