require 'spec_helper'

module Lester
  describe Cli do
    let :cli do
      described_class.new(argv, io)
    end

    let :io do
      StringIO.new
    end

    let :output do
      io.string
    end

    describe 'help|-h' do
      let :argv do
        ['help']
      end

      it 'prints usage' do
        cli.run
        expect(output).to match(/Usage/)
      end

      it 'returns an ok exit code' do
        code = cli.run
        expect(code).to eq(0)
      end
    end

    describe 'init' do
      let :command_name do
        'init'
      end

      context 'cli parameters' do
        context '-d / --domain DOMAIN' do
          parameter_validation 'domain'
        end

        context '-s / --storage-bucket NAME' do
          parameter_validation 'storage-bucket', 'storage bucket'
        end

        context '-p / --private-key PATH' do
          parameter_validation 'private-key', 'private key path'
        end
      end
    end

    describe 'renew|new' do
      let :command_name do
        'renew'
      end

      context 'cli parameters' do
        context '-d / --domain DOMAIN' do
          parameter_validation 'domain'
        end

        context '-s / --storage-bucket NAME' do
          parameter_validation 'storage-bucket', 'storage bucket'
        end

        context '-b / --site-bucket NAME' do
          parameter_validation 'site-bucket', 'site bucket'
        end

        context '-e / --email ADDRESS' do
          parameter_validation 'email'
        end
      end
    end

    describe 'any other command' do
      let :argv do
        ['other']
      end

      it 'prints an error message' do
        cli.run
        expect(output).to match(/Unknown command "other"/)
      end

      it 'prints usage' do
        cli.run
        expect(output).to match(/Usage/)
      end

      it 'returns a non-ok exit code' do
        code = cli.run
        expect(code).to eq(1)
      end
    end
  end
end
