class FakeCloudFront
  attr_reader :updates

  def initialize
    @config = {}
    @updates = []
  end

  def add_config(id, config)
    @config[id] = config
  end

  def get_distribution_config(args)
    if (id = args[:id])
      config = @config[id]
      response = OpenStruct.new
      response.distribution_config = config
      response.etag = 'ETAG-' + id
      response
    end
  end

  def update_distribution(args)
    @updates << args
  end
end
