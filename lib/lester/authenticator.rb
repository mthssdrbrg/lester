module Lester
  class Authenticator
    def initialize(bucket, options={})
      @bucket = bucket
      @sleeper = options[:sleeper] || Kernel
    end

    def authenticate(challenge)
      write(challenge)
      verify_status(challenge)
    end

    private

    def write(challenge)
      object = {
        key: challenge.filename,
        body: challenge.file_content,
        content_type: challenge.content_type,
        acl: 'public-read'
      }
      @bucket.put_object(object)
    end

    def verify_status(challenge)
      if challenge.request_verification
        until challenge.status != 'pending' || challenge.error do
          @sleeper.sleep(1)
          challenge.verify_status
        end
        if (error = challenge.error)
          raise RequestVerificationError, sprintf('%s: %s', error['type'], error['detail'])
        end
        if (status = challenge.status) != 'valid'
          raise RequestVerificationError, status
        end
      else
        raise RequestVerificationError
      end
    end
  end
end
