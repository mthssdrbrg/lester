require 'spec_helper'

module Lester
  describe Logger do
    let :logger do
      described_class.new(quiet, verbose, stdout, stderr)
    end

    let :stdout do
      StringIO.new
    end

    let :stderr do
      StringIO.new
    end

    let :quiet do
      false
    end

    let :verbose do
      false
    end

    describe 'default settings' do
      it 'does not log debug anywhere' do
        logger.debug('hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to be_empty
      end

      it 'logs info to stdout' do
        logger.info('info: hello world')
        expect(stdout.string).to eq(%(info: hello world\n))
        expect(stderr.string).to be_empty
      end

      it 'logs warn to stderr' do
        logger.warn('warn: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(warn: hello world\n))
      end

      it 'logs error to stderr' do
        logger.error('error: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(error: hello world\n))
      end

      it 'logs fatal to stderr' do
        logger.fatal('fatal: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(fatal: hello world\n))
      end

      it 'logs unknown to stderr' do
        logger.unknown('unknown: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(unknown: hello world\n))
      end
    end

    describe 'quiet setting' do
      let :quiet do
        true
      end

      it 'does not log debug anywhere' do
        logger.debug('debug: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to be_empty
      end

      it 'does not log info anywhere' do
        logger.info('info: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to be_empty
      end

      it 'logs warn to stderr' do
        logger.warn('warn: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(warn: hello world\n))
      end

      it 'logs error to stderr' do
        logger.error('error: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(error: hello world\n))
      end

      it 'logs fatal to stderr' do
        logger.fatal('fatal: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(fatal: hello world\n))
      end

      it 'logs unknown to stderr' do
        logger.unknown('unknown: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(unknown: hello world\n))
      end
    end

    describe 'verbose setting' do
      let :verbose do
        true
      end

      it 'logs debug to stdout' do
        logger.debug('debug: hello world')
        expect(stdout.string).to eq(%(debug: hello world\n))
        expect(stderr.string).to be_empty
      end

      it 'logs info to stdout' do
        logger.info('info: hello world')
        expect(stdout.string).to eq(%(info: hello world\n))
        expect(stderr.string).to be_empty
      end

      it 'logs warn to stderr' do
        logger.warn('warn: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(warn: hello world\n))
      end

      it 'logs error to stderr' do
        logger.error('error: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(error: hello world\n))
      end

      it 'logs fatal to stderr' do
        logger.fatal('fatal: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(fatal: hello world\n))
      end

      it 'logs unknown to stderr' do
        logger.unknown('unknown: hello world')
        expect(stdout.string).to be_empty
        expect(stderr.string).to eq(%(unknown: hello world\n))
      end
    end
  end
end
