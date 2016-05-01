=begin
	This file is responsible for accepting requests for data
	or responses containing data. It hands these requests and
	responses to the signalling and storage modules as appropriate.
=end

require_relative 'storage'
require_relative 'signal'
require_relative 'configuration'

get '/relay/:ttlOrig/:ttlCurrent/:request' do |orig_ttl, current_ttl, request|

end

post '/relay/:ttl/:request' do |ttl, request|

end
