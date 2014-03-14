#
# LazyConnectionPool
#
# A connection pool that lazily creates connections and can be 
# resized dynamically.  It attempts optimistic thread-safety.
#

require 'thread'

class LazyConnectionPool
  def initialize(poolsize=-1, &block)
    if block.nil?
      raise ArgumentError, "LazyConnectionPool requires a block"
    end

    @max_pool_size = poolsize
    @cur_pool_size = 0
    @block = block
    @pool = Queue.new
    @mutex = Mutex.new
  end

  def poolsize=(poolsize)
    to_release = 0

    @mutex.synchronize {
      @max_pool_size = poolsize
      if @max_pool_size >= 0
        to_release = (@max_pool_size - @cur_pool_size) 
        to_release = @pool.num_waiting if @pool.num_waiting < to_release
        to_release = 0 if to_release < 0
      else
        to_release = @pool.num_waiting
      end
    }

    if to_release > 0
      to_release.times { |x|
        self.release @block.call
      }
    end

    return @max_pool_size
  end

  def poolsize
    @max_pool_size
  end

  def get(should_wait=true, &block)
    cx = nil

    # get a cx from the pool
    begin
      # see if we can get one.  don't wait if we can't.
      cx = @pool.pop(true)
    rescue ThreadError
      # We did not get one.  Can we grow?
      if @max_pool_size < 0 or @cur_pool_size < @max_pool_size
        @mutex.synchronize {
          @cur_pool_size += 1
          if @max_pool_size >= 0 and @cur_pool_size > @max_pool_size
            # back out of our creation (unwind after detecting we lost a
            # a comparison race condition)
            @cur_pool_size -= 1
          else
            cx = @block.call
          end
        }
      end
    end

    if cx.nil?
      begin
        cx = @pool.pop(!should_wait)
      rescue ThreadError
        return nil
      end
    end

    # now we have a cx.
    if block.nil?
      return cx
    end

    begin
      r = yield cx
    ensure
      self.release(cx)
    end
    return r
  end

  def release(cx)
    if @max_pool_size < 0 or (@max_pool_size > 0 and @cur_pool_size <= @max_pool_size)
      @pool.push cx
    else
      @mutex.synchronize {
        @cur_pool_size -= 1
        @cur_pool_size = 0 if @cur_pool_size < 0
      }
      # XXX: close cx somehow?
    end
    nil
  end
end

