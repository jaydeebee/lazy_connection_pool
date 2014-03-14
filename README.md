LazyConnectionPooler
====================

A lazy connection pooler for Ruby.

This gem is meant to provide functionality similar to Mike Perham's lovely
[connection_pool](http://github.com/mperham/connection_pool), with the
twist that connections will be lazily created whenever there's a shortage
in the pool.  It is not, however, meant to be a drop-in replacement for
that library.

I've tested this lightly under CRuby 1.9.3 and JRuby 1.7.10, and it doesn't
appear to deadlock or step on itself, even when running hundreds of threads
battling for a handful of connections.  But my testing should hardly be a
promise that it's bug-free, or even functional.

Usage
=====

The documentation is, uhm, coming real soon now.  The following will have
to suffice in the meantime.

Pool creation
-------------

Initiate a pool, passing in a block that'll be used to initialize new
connections:

	pool = LazyConnectionPool.new {
		Net::HTTP.new('localhost')
	}

Connection usage: inline
------------------------

Your new `LazyConnectionPool` object's `#get` method can take a block.  It
will pass your block a connection:

	response = pool.get { |sock|
		sock.get('/')
	}

When used this way, `#get` will return te result of your block.  If your
block raises any exceptions, the connection will still be returned to the
pool, and the exception will be yours to handle.

Connection usage: get/release
-----------------------------

You can also request a connection, then release it when you're done with
it, by calling `#get` without a block:

	sock = pool.get
	response = sock.get('/')
	pool.release(sock)

Of course, if you don't ever `#release` your connection, it'll just leak
onto the floor.

Pool limits
-----------

You can optionally limit the size of the pool:

	pool.poolsize = 16

The default is a limit of `-1`, which is unlimited.  If you specify `0` as
a limit, no pool objects will be available.

Blocking requests
-----------------

If you run out of connections in the pool, such that you run into your
`poolsize` limit, `#get` will block until a connection is available.
`#get` takes one optional boolean argument, indicating whether it should
wait for a connection to become available.  If it's false, it'll return
`nil`.  Note that if you use a block with `#get` and it also potentially
returns `nil`, it could be difficult to differentiate between the two
conditions, as below:

	body = pool.get(false) { |sock|
		response = sock.get('/')
		if response.code.to_i == 200
			JSON.parse(response.body)
		end
	}

Would it have blocked?  Did it connect but the response was something other
than a 200?  The world may never know.

Unhealthy connections
---------------------

LazyConnectionPool assumes that the connections it hands out are healthy,
or can be made healthy without replacing the connection object.  If this
isn't true, LazyConnectionPool is not for you.  Your code should detect and
heal the connection object whenever needed.

Shrinking the pool
------------------

LazyConnectionPool adds connections to deal with shortages; it does not
reap them again, unless `poolsize` shrinks somehow.

Contributions
=============

Bug? Feature? Contributions of any kind: Send me a pull request.

