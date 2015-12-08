require 'spec_helper'

module Lester
  describe Authenticator do
    let :authenticator do
      described_class.new(bucket, sleeper: sleeper)
    end

    let :challenge do
      double(:challenge)
    end

    let :bucket do
      double(:bucket)
    end

    let :sleeper do
      double(:sleeper)
    end

    before do
      allow(challenge).to receive(:filename).and_return('challenge-filename')
      allow(challenge).to receive(:file_content).and_return('challenge-file-content')
      allow(challenge).to receive(:content_type).and_return('text/plain')
      allow(challenge).to receive(:request_verification).and_return(true)
      allow(challenge).to receive(:status).and_return('valid')
      allow(challenge).to receive(:error)
      allow(bucket).to receive(:put_object)
      allow(sleeper).to receive(:sleep)
    end

    describe '#authenticate' do
      it 'uses the challenge\'s filename as S3 key' do
        authenticator.authenticate(challenge)
        expect(bucket).to have_received(:put_object).with(hash_including(key: 'challenge-filename'))
      end

      it 'writes the challenge\'s content' do
        authenticator.authenticate(challenge)
        expect(bucket).to have_received(:put_object).with(hash_including(body: 'challenge-file-content'))
      end

      it 'uses `public-read` as acl' do
        authenticator.authenticate(challenge)
        expect(bucket).to have_received(:put_object).with(hash_including(acl: 'public-read'))
      end

      it 'requests verification' do
        authenticator.authenticate(challenge)
        expect(challenge).to have_received(:request_verification)
      end

      it 'raises an error when verification is refused' do
        allow(challenge).to receive(:request_verification).and_return(false)
        expect { authenticator.authenticate(challenge) }.to raise_error(RequestVerificationError)
      end

      context 'request verification' do
        it 'verifies the status of the challenge' do
          allow(challenge).to receive(:status).and_return('pending')
          allow(challenge).to receive(:verify_status) do
            allow(challenge).to receive(:status).and_return('valid')
          end
          authenticator.authenticate(challenge)
          expect(challenge).to have_received(:verify_status)
        end

        it 'raises an error when the verification returns an error' do
          allow(challenge).to receive(:error).and_return('type' => 'urn:acme:error:unauthorized', 'detail' => 'Invalid response: 404')
          expect { authenticator.authenticate(challenge) }.to raise_error(RequestVerificationError, 'urn:acme:error:unauthorized: Invalid response: 404')
        end

        it 'raises an error when the verification status is != valid' do
          allow(challenge).to receive(:status).and_return('invalid')
          expect { authenticator.authenticate(challenge) }.to raise_error(RequestVerificationError, 'invalid')
        end
      end
    end
  end
end
