require 'spec_helper'

describe 'bin/lester init' do
  include_context 'acceptance setup'

  let :command do
    Lester::Cli.new(argv, io)
  end

  let :argv do
    [
      'init',
      '--domain', 'example.org',
      '--storage-bucket', storage_bucket_name,
      '--private-key', private_key_path,
    ]
  end

  let :storage_bucket_name do
    'example-org-backup'
  end

  context 'when the private key exists' do
    it 'stores it' do
      command.run
      object = storage_bucket.object('account/private_key.json')
      expect { JSON::JWK.new(JSON.parse(object.read)).to_key }.to_not raise_error
    end

    it 'returns an ok exit code' do
      code = command.run
      expect(code).to eq(0)
    end
  end

  context 'when --storage-bucket includes a prefix' do
    let :storage_bucket_name do
      'example-org-backup/lester'
    end

    it 'stores it under the given prefix' do
      command.run
      object = storage_bucket.object('lester/account/private_key.json')
      expect { JSON::JWK.new(JSON.parse(object.read)).to_key }.to_not raise_error
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
