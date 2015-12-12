module Lester
  module Command
    class Renew
      def self.create(domain, key_size, factory)
        new(domain, factory.acme_client, factory.authenticator, factory.uploader, factory.certificate_store, key_size: key_size)
      end

      def initialize(domain, acme_client, authenticator, uploader, store, options={})
        @domain = domain
        @acme_client = acme_client
        @authenticator = authenticator
        @uploader = uploader
        @store = store
        @key_size = options[:key_size] || 2048
        @key_class = options[:key_class] || OpenSSL::PKey::RSA
        @csr_class = options[:csr_class] || Acme::CertificateRequest
      end

      def run
        auth
        renew
        upload
        store
      end

      private

      def auth
        domains.each do |domain|
          authorization = @acme_client.authorize(domain: domain)
          @authenticator.authenticate(authorization.http01)
        end
      end

      def renew
        key = @key_class.new(@key_size)
        @csr = @csr_class.new(names: domains, private_key: key)
        @certificate = @acme_client.new_certificate(@csr)
      end

      def upload
        certificate_name = sprintf('%s-%s', @domain, issue_date)
        @uploader.upload(certificate_name, @certificate, @csr.private_key)
      end

      def store
        @store.put(sprintf('%s/cert.pem', issue_date), @certificate.to_pem)
        @store.put(sprintf('%s/chain.pem', issue_date), @certificate.chain_to_pem)
        @store.put(sprintf('%s/fullchain.pem', issue_date), @certificate.fullchain_to_pem)
        @store.put(sprintf('%s/csr.pem', issue_date), @csr.to_pem)
        @store.put(sprintf('%s/privkey.pem', issue_date), @csr.private_key.to_pem)
      end

      def issue_date
        @issue_date ||= @certificate.x509.not_before.strftime('%Y%m%d%H%M')
      end

      def domains
        @domains ||= [@domain, sprintf('www.%s', @domain)]
      end
    end
  end
end
