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

post '/peer/pair' do
	Log.log("Pair", "Received a request to pair from #{request.ip}")
end

post '/peer/depeer' do
	Log.log("Pair", "Received a request to de-pair from #{request.ip}")
end

# This is a post request so the contents can contain
# a peerlist.
post '/peer/announcePeers/:ttl' do |ttl|
	Log.log("Pair", "Received a peer-list from #{request.ip}")
	peers = params['peers']
end
