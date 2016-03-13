module Lester
  module Command
    class Init
      def self.create(factory)
        new(factory.private_key, factory.key_name, factory.account_store)
      end

      def initialize(private_key, key_name, store)
        @private_key = private_key
        @key_name = key_name
        @store = store
      end

      def run
        @store.put(@key_name, @private_key.to_jwk.to_json)
      end
    end
  end
end
