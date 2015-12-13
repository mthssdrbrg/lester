require 'spec_helper'

module Lester
  describe S3Store do
    let :store do
      described_class.new(bucket, prefix, options)
    end

    let :bucket do
      double(:bucket)
    end

    let :prefix do
      'prefix'
    end

    let :options do
      {'silly' => 'option'}
    end

    let :object do
      double(:object)
    end

    before do
      allow(bucket).to receive(:object).with('prefix/key.ext').and_return(object)
      allow(bucket).to receive(:put_object)
      allow(object).to receive(:key).and_return('prefix/key.ext')
      allow(object).to receive(:get).and_return(object)
      allow(object).to receive(:body).and_return(object)
      allow(object).to receive(:read).and_return('content')
      allow(object).to receive(:exists?).and_return(true)
    end

    describe '#put' do
      it 'stores values under given prefix' do
        store.put('key.ext', 'content')
        expect(bucket).to have_received(:put_object).with(hash_including(key: 'prefix/key.ext'))
        expect(bucket).to have_received(:put_object).with(hash_including(body: 'content'))
      end

      it 'includes given options' do
        store.put('key.ext', 'content')
        expect(bucket).to have_received(:put_object).with(hash_including('silly' => 'option'))
      end
    end

    describe '#get' do
      it 'retrieves values from a prefix' do
        store.get('key.ext')
        expect(bucket).to have_received(:object).with('prefix/key.ext')
      end

      context 'returns something that responds to' do
        let :s3_object do
          store.get('key.ext')
        end

        it 'exists?' do
          expect(s3_object.exists?).to be true
        end

        it 'read' do
          expect(s3_object.read).to eq('content')
        end

        it 'extname' do
          expect(s3_object.extname).to eq('.ext')
        end
      end
    end
  end
end
