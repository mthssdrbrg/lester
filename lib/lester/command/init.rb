module Lester
  module Command
    class Init
      def self.create(factory)
        new(factory.private_key, factory.account_store)
      end

      def initialize(private_key, store)
        @private_key = private_key
        @store = store
      end

      def run
        @store.put(KEY_NAME, @private_key.to_jwk.to_json)
      end
    end
  end
end
