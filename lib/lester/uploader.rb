module Lester
  class Uploader
    def initialize(iam, cloudfront, distribution_id)
      @iam = iam
      @cloudfront = cloudfront
      @distribution_id = distribution_id
    end

    def upload(name, certificate, private_key)
      metadata = @iam.upload_server_certificate({
        path: '/cloudfront/',
        server_certificate_name: name,
        private_key: private_key.to_pem,
        certificate_body: certificate.to_pem,
        certificate_chain: certificate.chain_to_pem,
      }).server_certificate_metadata
      certificate_id = metadata.server_certificate_id
      response = @cloudfront.get_distribution_config(id: @distribution_id)
      distribution_config = response.distribution_config.to_hash
      distribution_config[:viewer_certificate][:iam_certificate_id] = certificate_id
      @cloudfront.update_distribution({
        distribution_config: distribution_config,
        id: @distribution_id,
        if_match: response.etag,
      })
    end
  end
end
