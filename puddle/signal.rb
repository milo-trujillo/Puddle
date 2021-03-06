require 'patron'
require 'set'
require 'thread'
require 'base64'
require 'cgi'
require_relative 'configuration'
require_relative 'log'

# This is a tiny wrapper that's easier to interpret than a tuple
# Works for 'get' or 'post' requests, where get is for requesting
# information, and 'post' is for sending responses with important data
class Request
	attr_reader :type, :request, :current_ttl
end

# Requests need to have a "response" ttl so nodes know how
# to reach us.
class DataRequest < Request
	attr_reader :orig_ttl
	def initialize(req, orig_ttl, current_ttl)
		@type = :get
		@request = req
		@orig_ttl = orig_ttl
		@current_ttl = current_ttl
	end
end

# A data response needs a data blob and filename in addition to the request
class DataResponse < Request
	attr_reader :data, :filename

	def initialize(request, filename, data, ttl)
		@request = request
		@type = :put
		@filename = filename
		@data = data
		@current_ttl = ttl
	end
end

module Signal
	@@toSend = Queue.new ## Must be threadsafe
	@@requests = Set.new
	@@peers = Set.new
	@@peerLock = Mutex.new

	# Sets up a timeout, executes a single request to a single host
	private_class_method def self.sendRequest(peer, req)
		if( req.type != :get and req.type != :put )
			Log.log("Signal", "Error! Invalid request type #{req.type}!")
			return
		end
		sess = Patron::Session.new
		sess.timeout = Configuration::TimeOut
		sess.base_url = "http://#{peer}:#{Configuration::Port}"
		sess.headers['User-Agent'] = Configuration::Agent
		request = CGI.escape(Base64.encode64(req.request))
		begin
			if( req.type == :get )
				sess.get("/relay/#{req.orig_ttl}/#{req.current_ttl}/#{request}")
			elsif( req.type == :put )
				filename = CGI.escape(Base64.encode64(req.filename))
				data = CGI.escape(Base64.encode64(req.data))
				url = "/relay/#{req.current_ttl}/#{request}/#{filename}"
				sess.put(url, data)
			end
		rescue => e
			# This is normal since the other end drops our connections
			Log.log("Signal", "Error during message transmit: #{e.message}")
		end
	end

	private_class_method def self.sendData()
		Log.log("Signal", "Started message transmission thread.")
		while( true ) do
			msg = @@toSend.pop
			peers = nil
			@@peerLock.synchronize do
				peers = @@peers.dup
			end
			for peer in peers do
				sendRequest(peer, msg)
			end
			Log.log("Signal", "Sent request: #{msg.request}")
		end
		Log.log("Signal", "WARNING: Thread is exiting, should not happen!")
	end
	
	def self.init
		(0 .. Configuration::NetThreads - 1).each do
			Thread.new do
				sendData()
			end
		end

		Log.log("Signal", "Message passing system started.")
	end

	# Adds a new request for information if we haven't already requested it
	def self.addRequest(req)
		if( @@requests.add?(req) != nil )
			# TODO: CHANGE THE TTLS BELOW TO ADD ANONYMITY
			@@toSend << DataRequest.new(req, 5, 5)
		end
		Log.log("Signal", "Added request for #{req}")
	end

	def self.forwardRequest(req, orig_ttl, current_ttl)
		if( current_ttl.to_i <= 1 )
			Log.log("Signal", "Dropping request for #{req}")
			return
		end
		@@toSend << DataRequest.new(req, orig_ttl.to_i, current_ttl.to_i - 1)
		Log.log("Signal", "Forwarding request for #{req} (TTL #{current_ttl})")
	end

	def self.forwardResponse(topic, filename, data, ttl)
		if( ttl.to_i <= 1 )
			Log.log("Signal", "Dropping response for #{topic} with file #{filename}")
			return
		end
		eTopic = topic
		eName = filename
		@@toSend << DataResponse.new(eTopic, eName, data, ttl.to_i-1)
		Log.log("Signal", "Forwarding response for #{topic} with file #{filename} (TTL #{ttl})")
	end

	def self.addPeer(address)
		@@peerLock.synchronize do
			@@peers.add?(address)
		end
		Log.log("Signal", "Added peer #{address}")
	end

	def self.dropPeer(address)
		@@peerLock.synchronize do
			@@peers.delete?(address)
		end
		Log.log("Signal", "Dropped peer #{address}")
	end

	# Returns every request we're currently accepting responses for
	def self.activeRequests()
		return @@requests.to_a
	end

	# Returns whether a particular topic is actively being requested
	def self.isActiveRequest?(topic)
		return @@requests.include?(topic)
	end
end
