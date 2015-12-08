class FakeIAM
  attr_reader :certificates

  def initialize
    @certificates = []
  end

  def upload_server_certificate(args)
    @certificates << args
  end
end
