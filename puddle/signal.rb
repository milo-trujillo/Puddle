require 'patron'
require 'set'
require 'thread'
require 'base64'
require_relative 'configuration'
require_relative 'log'

# This is a tiny wrapper that's easier to interpret than a tuple
# Works for 'get' or 'post' requests, where get is for requesting
# information, and 'post' is for sending responses with important data
class Request
	attr_reader :type, :request, :current_ttl
=begin
	def initialize(type, request, current_ttl)
		@type = type
		@request = request
		@current_ttl = current_ttl
	end
=end
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

	private_class_method def self.sendData()
		Log.log("Signal", "Started message transmission thread.")
		while( true ) do
			msg = @@toSend.pop
			peers = nil
			@@peerLock.synchronize do
				peers = @@peers.dup
			end
			for peer in peers do
				# TODO: Send to each peer here
			end
			Log.log("Signal", "Would have sent request: #{Base64.decode64(msg.request)}")
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
			@@toSend << DataRequest.new(Base64.encode64(req), 1, 1)
		end
		Log.log("Signal", "Added request for #{req}")
	end

	def self.forwardRequest(req, orig_ttl, current_ttl)
		if( current_ttl <= 1 )
			Log.log("Signal", "Dropping request for #{req}")
			return
		end
		@@toSend << DataRequest.new(Base64.encode64(req), orig_ttl, current_ttl - 1)
		Log.log("Signal", "Forwarding request for #{req}")
	end

	def self.forwardResponse(topic, filename, data, ttl)
		if( ttl <= 1 )
			Log.log("Signal", "Dropping response for #{topic} with file #{filename}")
			return
		end
		eTopic = Base64.encode64(topic)
		eName = Base64.encode64(filename)
		@@toSend << DataResponse.new(eTopic, eName, data, ttl-1)
		Log.log("Signal", "Forwarding response for #{topic} with file #{filename}")
	end

	def self.addPeer(address)
		@@peerLock.synchronize do
			@@peers.add?(address)
		end
	end

	def self.dropPeer(address)
		@@peerLock.synchronize do
			@@peers.delete?(address)
		end
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
