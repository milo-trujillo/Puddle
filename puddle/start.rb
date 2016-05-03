#!/usr/bin/env ruby

require "sinatra"
require "tilt/erb"

require_relative "configuration"
require_relative "state"
require_relative "signal"
require_relative "storage"
require_relative "client"
require_relative "relay"
require_relative "peer"
require_relative "log"

set :bind => "0.0.0.0"
set :port => Configuration::Port
Thread.abort_on_exception = true

State.init
Log.init
Signal.init

get '/' do
	redirect to('/client/')
end

if( ARGV.length != 0 )
	Log.log("Core", "Adding #{ARGV.length} peers")
	for peer in ARGV
		Signal.addPeer(peer)
	end
end
