#!/usr/bin/env ruby

require "sinatra"
require "tilt/erb"

require_relative "configuration"
require_relative "signal"
require_relative "storage"
require_relative "client"
require_relative "log"

set :bind => "0.0.0.0"
set :port => Configuration::Port

Log.init
Signal.init

get '/' do
	redirect to('/client/')
end
