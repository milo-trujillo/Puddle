=begin
	This file handles peering and de-peering of other relays.

	Note: /peer/pair and /peer/depeer are DIRECT connections to
	our relay, they are NOT rippled through the anonymity network.

	By contrast, /peer/announcePeers IS rippled, and is a way
	for each relay to announce its peers, and is performed
	automatically at set intervals.
=end

require_relative 'signal'
require_relative 'log'
require_relative 'configuration'

post '/peer/pair/' do
	Log.log("Pair", "Received a request to pair from #{request.ip}")
	Peer.addPeer(request.ip)
	return 'accepted'
# TODO: Properly set up a system for deciding whether or not to reject peering requests
#	return 'rejected'
end

post '/peer/depeer' do
	# if we receive a depeer request, we remove them from our list of peers
	Peer.removePeer(request.ip)
	# and log that they have been depeered
	Log.log("Pair", "Received a request to de-pair from #{request.ip}")
end

# This is a post request so the contents can contain
# a peerlist.
post '/peer/announcePeers/:ttl' do |ttl|
	
	Log.log("Pair", "Received a peer-list from #{request.ip}")
	peers = params['peers']
	Peer.advanceRipple(ttl, peers)
end

module Peer

	@@myPeers = ['localhost']


	def self.initialize()
		myPeers.add('localhost')
	end

	def self.addPeer( ip )
		@@myPeers += [ip]
	end

	def self.listPeers()
		@@myPeers.each do |ip|
			puts ip
		end
	end

	def self.requestPeer( ip )
		# initialize session stuff
		sess = Patron::Session.new
		sess.timeout = Configuration::TimeOut
		sess.base_url = "http://#{ip}:#{Configuration::Port}"
		sess.headers['User-Agent'] = Configuration::Agent

		# myip = 10.0.0.1
		resp = sess.post("/peer/pair", {})
		if(resp)
			addPeer(ip)
		end
	end

	def self.dePeer( ip )
		# port should be Configuration::port
		sess = Patron::Session.new
		sess.timeout = Configuration::TimeOut
		sess.base_url = "http://#{ip}:#{Configuration::Port}"
		sess.headers['User-Agent'] = Configuration::Agent
		sess.post("/peer/depeer", {})
	end

	def self.peerRipple()
		sess = Patron::Session.new
		sess.timeout = Configuration::TimeOut
		sess.headers['User-Agent'] = Configuration::Agent
		header = "/peer/announcepeers/#{ttl}"
		@@myPeers.each do |ip|
			sess.base_url = "http://#{ip}:#{Configuration::Port}"
			sess.post(header, {:peers => @@myPeers})
		end
	end

	def self.advanceRipple(ttl, peers)
		sess = Patron::Session.new
		sess.timeout = Configuration::TimeOut
		sess.header['User-Agent'] = Configuration::Agent
		if(ttl == 1)
			return
		end
		@@myPeers.each do |ip|
			ttl -= 1
			sess.base_url = "http://#{ip}:#{Configuration::Port}"
			header = "/peer/accouncepeets/#{ttl}"
			sess.post(header, {:peers => @@myPeers})
		end
	end

	def self.removePeer(ip)
		@@myPeers -= [ip]
	end

end
