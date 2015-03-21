module Anemone
  module Queue
    class Sized < DelegateClass(SizedQueue)

      def initialize(max)
        super SizedQueue.new(max)
      end

    end
  end
end