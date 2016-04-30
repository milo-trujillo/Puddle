require_relative "configuration"
require_relative "log"

=begin
	This file is responsible for generating the UI every human
	user will interact with. It calls out to other modules
	to get work done.
=end

get '/client' do
	redirect to("/client/")
end

get "/client/" do
	uptime = Log.uptime
	erb :index, :locals => {:uptime => uptime}
end

get '/client/about' do
	erb :about
end

get '/client/shared' do
	erb :shared, :locals => {:sharedDir => Configuration::DataDir}
end

get '/client/downloads' do
	erb :downloads
end

get '/client/cache' do
	erb :cache
end

get '/client/log' do
	data = Log.read
	erb :log, :locals => {:log => data}
end
