require "thread"

require_relative "configuration"

=begin
	This module provides logging for the rest of Puddle.
=end

module Log
	@@start = Time.new
	@@lock = Mutex.new

	def self.init
		@@lock.synchronize do
			if( File.exists?(Configuration::LogFile) )
				File.delete(Configuration::LogFile)
			end
			f = File.open(Configuration::LogFile, "w")
			f.close
		end
		Log.log("Core", "Relay started.")
	end

	def self.log(type, message)
		t = Time.new
		timestamp = "[#{t.month}/#{t.day} #{t.hour}:#{t.min}:#{t.sec}]"
		@@lock.synchronize do
			f = File.open(Configuration::LogFile, "a")
			f.flock(File::LOCK_EX)
			f.printf("%-16s %-10s: %s\n", timestamp, type, message)
			f.close
		end
	end
	
	def self.read
		@@lock.synchronize do
			return File.read(Configuration::LogFile)
		end
	end

	def self.read_backwards
		data = ""
		@@lock.synchronize do
			data = File.read(Configuration::LogFile)
		end
		log = ""
		data.lines.reverse_each do |line|
			log += line
		end
		return log
	end

	def self.uptime
		return (Time.new - @@start)
	end
end
