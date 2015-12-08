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
        allow(private_key).to receive(:to_pem).and_return('PEM')
        allow(store).to receive(:put)
      end

      describe '#run' do
        it 'unconditionally stores the key in PEM format' do
          command.run
          expect(store).to have_received(:put).with('private_key.pem', 'PEM')
        end
      end
    end
  end
end
