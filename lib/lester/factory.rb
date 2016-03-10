module Lester
  class Factory
    def initialize(config)
      @config = config
    end

    def authenticator
      @authenticator ||= Authenticator.new(site_bucket)
    end

    def uploader
      @uploader ||= Uploader.new(iam, cloudfront, @config[:distribution_id])
    end

    def acme_client
      @acme_client ||= Acme::Client.new(private_key: private_key, endpoint: @config[:endpoint])
    end

    def account_store
      @account_store ||= create_store('account')
    end

    def certificate_store
      @certificate_store ||= create_store(sprintf('certificates/%s', @config[:domain]))
    end

    def private_key
      @private_key ||= begin
        if (key_path = @config[:private_key_path])
          PrivateKey.new(Pathname.new(key_path)).load
        else
          PrivateKey.new(account_store.get(key_name)).load
        end
      end
    end

    def key_name
      @key_name ||= sprintf('%s.json', @config[:key_name] || 'private_key')
    end

    private

    def create_store(suffix)
      uri = URI(sprintf('s3://%s', @config[:storage_bucket]))
      bucket_name = uri.host
      prefix = sprintf('%s/%s', uri.path, suffix).sub('/', '')
      bucket = Aws::S3::Bucket.new(bucket_name)
      S3Store.new(bucket, prefix, store_options)
    end

    def store_options
      @store_options ||= begin
        options = {server_side_encryption: 'AES256'}
        if (kms_key_id = @config[:kms_key_id])
          options[:server_side_encryption] = 'aws:kms'
          options[:ssekms_key_id] = kms_key_id
        end
        options
      end
    end

    def site_bucket
      @site_bucket ||= Aws::S3::Bucket.new(@config[:site_bucket])
    end

    def iam
      @iam ||= Aws::IAM::Client.new
    end

    def cloudfront
      @cloudfront ||= Aws::CloudFront::Client.new
    end
  end
end
