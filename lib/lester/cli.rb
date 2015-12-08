require 'optparse'

module Lester
  class Cli
    def initialize(argv=ARGV, io=$stderr, option={})
      @command = argv.shift || 'help'
      @argv = argv
      @io = io
      @key_size = 2048
      @endpoint = 'https://acme-v01.api.letsencrypt.org/'
    end

    def run
      parse_argv
      dispatch
      0
    rescue OptionParser::ParseError, RequiredArgumentError, UnkownCommandError => e
      @io.puts(sprintf('%s (%s)', e.message, e.class.name))
      @io.puts(option_parser)
      1
    rescue => e
      @io.puts(sprintf('%s (%s)', e.message, e.class.name))
      1
    end

    private

    HELP_REGEX = /help|-h/.freeze

    def parse_argv
      option_parser.parse(@argv)
      unless @command =~ HELP_REGEX
        case @command
        when 'init'
          validate(@domain, 'domain is required')
          validate(@storage_bucket, 'storage bucket is required')
          validate(@private_key_path, 'private key path is required')
        when 'new', 'renew'
          validate(@domain, 'domain is required')
          validate(@storage_bucket, 'storage bucket is required')
          validate(@site_bucket, 'site bucket is required')
          validate(@email, 'email is required')
        else
          raise UnkownCommandError, sprintf('Unknown command %p, expected "init" or "re|new"', @command)
        end
      end
    end

    def validate(arg, message)
      if arg.nil? || arg.empty?
        raise RequiredArgumentError, message
      end
    end

    def dispatch
      case @command
      when HELP_REGEX
        @io.puts(option_parser)
      when 'init'
        Command::Init.create(factory).run
      when 'new', 'renew'
        Command::Renew.create(@domain, @key_size, factory).run
      end
    end

    def option_parser
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = %(Usage: lester init [options]\n       lester new [options])
        opts.separator ''
        opts.separator 'Common options:'
        opts.on('-d', '--domain=NAME', 'Domain name (required)') { |d| @domain = d }
        opts.on('-s', '--storage-bucket=BUCKET', 'S3 bucket for storing keys and certificates (required)') { |b| @storage_bucket = b }
        opts.on('-K', '--kms-id=KEY_ID', 'AWS KMS Key ID') { |k| @kms_key_id = k }
        opts.separator ''
        opts.separator 'init options:'
        opts.on('-p', '--private-key=PATH', 'Path to private key (required)') { |p| @private_key_path = p }
        opts.separator ''
        opts.separator 're|new options:'
        opts.on('-E', '--endpoint=ENDPOINT', sprintf('ACME endpoint (default: %s)', @endpoint)) { |e| @endpoint = e }
        opts.on('-b', '--site-bucket=BUCKET', 'S3 bucket for site (required)') { |b| @site_bucket = b }
        opts.on('-k', '--key-size=BITS', sprintf('Key size (in bits) (default: %d)', @key_size)) { |s| @key_size = s.to_i }
        opts.on('-e', '--email=ADDRESS', 'Registered email address') { |e| @email = e }
        opts.separator ''
      end
    end

    def factory
      @factory ||= Factory.new({
        domain: @domain,
        storage_bucket: @storage_bucket,
        kms_key_id: @kms_key_id,
        endpoint: @endpoint,
        site_bucket: @site_bucket,
        private_key_path: @private_key_path,
      })
    end
  end
end
