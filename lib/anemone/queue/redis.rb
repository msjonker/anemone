begin
  require 'redis'
rescue LoadError
  puts "You need the redis-client gem to use Anemone::Queue::Redis"
  exit
end

module Anemone
  module Queue
    class Redis

      def initialize(opts = {})
        @opts = opts
        @list = "#{@opts[:key_prefix] || 'anemone'}:queue"
        @waiting = "#{@list}:waiting"
        clear
      end

      def push(job)
        redis.lpush(@list,job)
      end
      alias_method :enq, :push
      alias_method :<<, :push

      def pop(non_block=false)
        redis.incr(@waiting)
        job = redis.brpop(@list, @opts[:timeout] || 0)
        redis.decr(@waiting)
        job.last rescue nil
      end
      alias_method :deq, :pop
      alias_method :shift, :pop

      def empty?
        size == 0
      end

      def size
        redis.llen(@list)
      end

      def num_waiting
        redis.get(@waiting).to_i
      end

      def clear
        redis.del(@list, @waiting)
      end

      private

      def redis
        Thread.current[:redis] ||= ::Redis.new(@opts)
      end

    end
  end
end