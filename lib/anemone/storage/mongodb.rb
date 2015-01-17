begin
  require 'moped'
  require 'bson'
  require 'bson/binary'
rescue LoadError
  puts "You need the moped gem to use Anemone::Storage::MongoDB"
  exit
end

module Anemone
  module Storage
    class MongoDB 

      BINARY_FIELDS = %w(body headers data)

      def initialize(mongo_db, collection_name)
        @db = mongo_db
        @collection = @db[collection_name]
        @collection.drop
        @collection.indexes.create(url: 1)
      end

      def [](url)
        if value = @collection.find('url' => url.to_s).one
          load_page(value)
        end
      end

      def []=(url, page)
        hash = page.to_hash
        BINARY_FIELDS.each do |field|
          hash[field] = BSON::Binary.new(hash[field]) unless hash[field].nil?
        end
        @collection.find('url' => page.url.to_s).upsert(hash)
      end

      def delete(url)
        page = self[url]
        @collection.find('url' => url.to_s).remove_all
        page
      end

      def each
        @collection.find do |cursor|
          cursor.each do |doc|
            page = load_page(doc)
            yield page.url.to_s, page 
          end
        end
      end

      def merge!(hash)
        hash.each { |key, value| self[key] = value }
        self
      end

      def size
        @collection.count
      end

      def keys
        keys = []
        self.each { |k, v| keys << k.to_s }
        keys
      end

      def has_key?(url)
        !!@collection.find('url' => url.to_s).one
      end

      def close
        @db.session.disconnect
      end

      private

      def load_page(hash)
        BINARY_FIELDS.each do |field|
          hash[field] = hash[field].to_s
        end
        Page.from_hash(hash)
      end

    end
  end
end

