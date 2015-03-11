begin
  require 'mongoid'
  require 'bson'
rescue LoadError
  puts "You need the mongoid gem to use Anemone::Storage::Mongoid"
  exit
end

module Anemone
  module Storage
    class Mongoid

      BINARY_FIELDS = %w(body headers data)

      def initialize(model_name)
        @model = model_name.is_a?(String) ? model_name.classify.constantize : model_name
        @model.destroy_all
        @model.create_indexes #'url'
      end

      def [](url)
        if value = @model.where(:url_digest => Digest::MD5.hexdigest(url.to_s)).first
          load_page(value)
        end
      end

      def []=(url, page)
        hash = page.to_hash
        BINARY_FIELDS.each do |field|
          hash[field] = BSON::Binary.new(hash[field], :generic) unless hash[field].nil?
        end
        page = @model.find_by(:url_digest => Digest::MD5.hexdigest(url.to_s))
        unless page
          page = @model.create(:url => url.to_s)
        end
        page.update_attributes(hash)
      end

      def delete(url)
        page = self[url]
        @model.destroy(:url_digest => Digest::MD5.hexdigest(url.to_s))
        page
      end

      def each
        @model.each do |doc|
          page = load_page(doc)
          yield page.url.to_s, page
        end
      end

      def merge!(hash)
        hash.each { |key, value| self[key] = value }
        self
      end

      def size
        @model.count
      end

      def keys
        keys = []
        self.each { |k, v| keys << k.to_s }
        keys
      end

      def has_key?(url)
        !!@model.where(:url_digest => Digest::MD5.hexdigest(url.to_s)).first
      end

      def close

      end

      private

      def load_page(doc)
        BINARY_FIELDS.each do |field|
          doc.send("#{field}=", doc.send(field).to_s)
        end
        Page.from_hash(doc)
      end

    end
  end
end