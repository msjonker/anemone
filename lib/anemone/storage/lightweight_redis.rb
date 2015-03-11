require 'redis'

module Anemone
  module Storage
    class LightweightRedis

      MARSHAL_FIELDS = %w(links visited fetched)

      def initialize(opts = {})
        @redis = ::Redis.new(opts)
        @key_prefix = opts[:key_prefix] || 'anemone'
        @url_hll = 'anemone:urls'
        @redis.del @url_hll
      end

      def [](key)
        raise
      end

      def []=(key, value)
        @redis.pfadd(@url_hll, key)
      end

      def delete(key)
        raise
      end

      def each
        raise
      end

      def merge!(hash)

      end

      def size
        @redis.pfcount
      end

      def keys
        raise
      end

      def has_key?(key)
        @redis.pfadd(@url_hll, key) == 1
      end

      def close
        @redis.quit
      end

      private

      def load_value(hash)
        raise
      end

      def rget(rkey)
        raise
      end

    end
  end
end
