class FakeBucket
  attr_reader :name

  def initialize(name)
    @name = name
    @store = Hash.new { |h, k| h[k] = [] }
  end

  def keys
    @store.keys
  end

  def object(key)
    @store[key]
  end

  def put_object(args)
    if (key = args.delete(:key))
      @store[key] = ObjectProxy.new(key, args.delete(:body), args)
    else
      raise ArgumentError, sprintf('mmissing :key in %p', args)
    end
  end

  class ObjectProxy
    attr_reader :key, :options

    def initialize(key, body, options)
      @key = key
      @body = body
      @options = options
    end

    def exists?
      true
    end

    def get
      self
    end

    def body
      self
    end

    def read
      if @body.respond_to?(:read)
        @body.read
      else
        @body
      end
    end
  end
end
