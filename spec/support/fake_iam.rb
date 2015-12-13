class FakeIAM
  attr_reader :certificates

  def initialize
    @certificates = []
  end

  def upload_server_certificate(args)
    @certificates << args
    metadata = OpenStruct.new
    metadata.server_certificate_id = Digest::MD5.hexdigest(args[:server_certificate_name])
    response = OpenStruct.new
    response.server_certificate_metadata = metadata
    response
  end
end
