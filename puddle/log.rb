require_relative "configuration"

=begin
	This module provides logging for the rest of Puddle.
=end

module Log
	@@start = Time.new

	def self.init
		if( File.exists?(Configuration::LogFile) )
			File.delete(Configuration::LogFile)
		end
		f = File.open(Configuration::LogFile, "w")
		f.close
		Log.log("Core", "Relay started.")
	end

	def self.log(type, message)
		t = Time.new
		timestamp = "[#{t.month}/#{t.day} #{t.hour}:#{t.min}:#{t.sec}]"
		f = File.open(Configuration::LogFile, "a")
		f.flock(File::LOCK_EX)
		f.printf("%-16s %-10s: %s\n", timestamp, type, message)
		f.close
	end
	
	def self.read
		return File.read(Configuration::LogFile)
	end

	def self.read_backwards
		data = File.read(Configuration::LogFile)
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
