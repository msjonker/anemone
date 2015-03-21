module Anemone
  module Tentacle
    class Base

      #
      # Create a new Tentacle
      #
      def initialize(link_queue, page_queue, opts = {})
        @link_queue = link_queue
        @page_queue = page_queue
        @opts = opts
      end

      #
      # Gets links from @link_queue, and returns the fetched
      # Page objects into @page_queue
      #
      def run
        loop do
          link, referer, depth = @link_queue.deq

          break if link == 'END'

          fetch_pages(link, referer, depth)

          delay
        end
      end

      def fetch_pages(link, referer, depth)
        raise NotImplementedError
      end

      private

      def delay
        sleep @opts[:delay] if @opts[:delay] > 0
      end
    end
  end
end
