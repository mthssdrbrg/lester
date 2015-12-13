module Lester
  class S3Store
    def initialize(bucket, prefix, options={})
      @bucket = bucket
      @prefix = prefix
      @options = options
    end

    def get(name)
      Proxy.new(@bucket.object(format_name(name)))
    end

    def put(name, contents)
      @bucket.put_object(@options.merge(key: format_name(name), body: contents))
    end

    private

    def format_name(name)
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
