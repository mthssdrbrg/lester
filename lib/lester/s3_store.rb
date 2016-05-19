module Lester
  class S3Store
    def initialize(bucket, prefix, options={})
      @bucket = bucket
      @prefix = prefix
      @options = options.dup
      @logger = @options.delete(:logger) || NullLogger.new
    end

    def get(name)
      prefixed_name = prefix_name(name)
      @logger.debug(sprintf('Fetching %p at %p', name, prefixed_name))
      Proxy.new(@bucket.object(prefixed_name))
    end

    def put(name, contents)
      prefixed_name = prefix_name(name)
      @logger.debug(sprintf('Storing %p at %p', name, prefixed_name))
      @bucket.put_object(@options.merge(key: prefixed_name, body: contents))
    end

    private

    def prefix_name(name)
      sprintf('%s/%s', @prefix, name)
    end

    class Proxy
      def initialize(object)
        @path = Pathname.new(object.key)
        @object = object
      end

      def exists?
        @object.exists?
      end

      def read
        @object.get.body.read
      end

      def extname
        @path.extname
      end
    end
  end
end
