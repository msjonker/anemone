module Anemone
  module Queue
    class Sized < DelegateClass ::Queue

      def initialize(max)
        super ::SizedQueue.new(max)
      end

    end
  end
end