=begin
	This file is responsible for accepting requests for data
	or responses containing data. It hands these requests and
	responses to the signalling and storage modules as appropriate.
=end

require 'base64'

require_relative 'storage'
require_relative 'signal'
require_relative 'configuration'
require_relative 'log'

# TODO: Validate that the TTLs are integers and that the topic makes sense
get '/relay/:ttlOrig/:ttlCurrent/:topic' do |orig_ttl, current_ttl, topic|
	topic = Base64.decode64(topic)
	Log.log("Relay", "Received a topic request on #{topic} from #{request.ip}")
	Signal.forwardRequest(topic, orig_ttl, current_ttl)
	files = Storage.findFiles(topic)
	for file in files
		# TODO: Change this so we *don't* read the whole file into RAM
		Signal.forwardResponse(topic, file, File.read(file), orig_ttl + 1)
	end
end

# TODO: Validate ttl, topic, filename, and data
# Make sure data isn't too rediculously large
post '/relay/:ttl/:topic/:filename' do |ttl, topic, filename|
	Log.log("Relay", "Received data response on #{topic} from #{request.ip}")
	data = params['data']
	Signal.forwardResponse(topic, filename, data, ttl)
	if( Signal.isActiveRequest?(topic) )
		Storage.storeFile(filename, data)
	end
end
