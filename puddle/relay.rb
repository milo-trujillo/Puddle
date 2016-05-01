=begin
	This file is responsible for accepting requests for data
	or responses containing data. It hands these requests and
	responses to the signalling and storage modules as appropriate.
=end

require_relative 'storage'
require_relative 'signal'
require_relative 'configuration'
require_relative 'log'

get '/relay/:ttlOrig/:ttlCurrent/:topic' do |orig_ttl, current_ttl, topic|
	Log.log("Relay", "Received a topic request on #{topic} from #{request.ip}")
end

post '/relay/:ttl/:topic/:filename' do |ttl, topic, filename|
	Log.log("Relay", "Received data response on #{topic} from #{request.ip}")
end
