#!/usr/bin/env ruby

require "sinatra"

require_relative "configuration"
require_relative "storage"
require_relative "client"

set :bind => "0.0.0.0"
set :port => Configuration::Port

get '/' do
	redirect to('/client/')
end
