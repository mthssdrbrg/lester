module Lester
  class Uploader
    def initialize(iam)
      @iam = iam
    end

    def upload(name, certificate, private_key)
      @iam.upload_server_certificate({
        path: '/cloudfront/',
        server_certificate_name: name,
        private_key: private_key.to_pem,
        certificate_body: certificate.to_pem,
        certificate_chain: certificate.chain_to_pem,
      })
    end
  end
end
