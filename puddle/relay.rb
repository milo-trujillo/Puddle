=begin
	This file is responsible for accepting requests for data
	or responses containing data. It hands these requests and
	responses to the signalling and storage modules as appropriate.
=end

require 'base64'
require 'cgi'

require_relative 'storage'
require_relative 'signal'
require_relative 'configuration'
require_relative 'log'

# TODO: Validate that the TTLs are integers and that the topic makes sense
get '/relay/:ttlOrig/:ttlCurrent/:topic' do |orig_ttl, current_ttl, topic|
	topic = Base64.decode64(CGI.unescape(topic))
	Log.log("Relay", "Received a topic request on #{topic} from #{request.ip}")
	Signal.forwardRequest(topic, orig_ttl.to_i, current_ttl.to_i)
	files = Storage.findFiles(topic)
	for file in files
		# TODO: Change this so we *don't* read the whole file into RAM
		name = File.basename(file)
		data = File.read(file)
		Signal.forwardResponse(topic, name, data, orig_ttl.to_i + 1)
	end
end

# TODO: Validate ttl, topic, filename, and data
# Make sure data isn't too rediculously large
put '/relay/:ttl/:topic/:filename' do |ttl, topic, filename|
	topic = Base64.decode64(CGI.unescape(topic))
	filename = Base64.decode64(CGI.unescape(filename))
	Log.log("Relay", "Received data response on #{topic} from #{request.ip}")
	# We use request.body.read to pull out the contents of the PUT
	data = Base64.decode64(CGI.unescape(request.body.read))
	Signal.forwardResponse(topic, filename, data, ttl.to_i)
	if( Signal.isActiveRequest?(topic) )
		Storage.storeFile(filename, data)
	else
		#Storage.cacheFile(filename, data)
	end
end
