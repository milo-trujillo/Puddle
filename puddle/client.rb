require_relative "configuration"
require_relative "log"
require_relative "signal"

=begin
	This file is responsible for generating the UI every human
	user will interact with. It calls out to other modules
	to get work done.
=end

before '/client/*' do
	# This is where we'll check to make sure you're connected from
	# localhost, and redirect you to a forbidden page otherwise
	if( request.ip != "127.0.0.1" )
		halt 403
	end
end

get '/client' do
	redirect to("/client/")
end

get "/client/" do
	uptime = Log.uptime
	requests = Signal.activeRequests
	erb :index, :locals => {:uptime => uptime, :requests => requests}
end

get '/client/about' do
	erb :about
end

get '/client/shared' do
	files = ["illuminati.pdf"]
	erb :shared, :locals => {:sharedDir => Configuration::DataDir, :files => files}
end

get '/client/downloads' do
	files = ["illuminati-song.mp3", "illuminati-proof.jpg"]
	erb :downloads, :locals => {:files => files}
end

get '/client/cache' do
	files = ["mcdonalds-menu.pdf", "SICP.pdf", "sheeple.png"]
	erb :cache, :locals => {:files => files}
end

get '/client/log' do
	data = Log.read_backwards
	erb :log, :locals => {:log => data}
end

post '/client/addRequest' do
	request = params['request']
	if( request != nil and request.length > 0 )
		Signal.addRequest(request)
	end
	redirect to('/client/')
end
