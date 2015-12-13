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
      @certificate_store ||= create_store('certificates')
    end

    def private_key
      @private_key ||= begin
        if (key_path = @config[:private_key_path])
          PrivateKey.new(Pathname.new(key_path)).load
        else
          PrivateKey.new(account_store.get(KEY_NAME)).load
        end
      end
    end

    private

    def create_store(suffix)
      S3Store.new(storage_bucket, sprintf('%s/%s', @config[:domain], suffix), store_options)
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

    def storage_bucket
      @storage_bucket ||= Aws::S3::Bucket.new(@config[:storage_bucket])
    end

    def iam
      @iam ||= Aws::IAM::Client.new
    end

    def cloudfront
      @cloudfront ||= Aws::CloudFront::Client.new
    end
  end
end
