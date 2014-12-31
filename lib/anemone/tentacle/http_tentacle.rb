require 'anemone/http'

module Anemone
  module Tentacle
    class HttpTentacle < Base

      def initialize(link_queue, page_queue, opts = {})
        @http = Anemone::HTTP.new(opts)
        super
      end

      def fetch_pages(link, referer, depth)
        @http.fetch_pages(link, referer, depth).each { |page| @page_queue << page }
      end

    end
  end
end
