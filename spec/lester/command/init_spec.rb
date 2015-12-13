require 'spec_helper'

module Lester
  module Command
    describe Init do
      let :command do
        described_class.new(private_key, store)
      end

      let :private_key do
        double(:private_key)
      end

      let :store do
        double(:store)
      end

      before do
        allow(private_key).to receive(:to_jwk).and_return({})
        allow(store).to receive(:put)
      end

      describe '#run' do
        it 'unconditionally stores the key in JSON JWK format' do
          command.run
          expect(store).to have_received(:put).with('private_key.json', '{}')
        end
      end
    end
  end
end
