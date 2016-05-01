=begin
	This file is responsible for making sure appropriate directories are
	in place before we start. Maybe later it will do other things, for now
	it's minimal.
=end

require_relative 'configuration'

module State
	def self.init
		unless(Dir.exists?(Configuration::PrivateFolder))
			Dir.mkdir(Configuration::PrivateFolder)
		end
		unless(Dir.exists?(Configuration::DataDir))
			Dir.mkdir(Configuration::DataDir)
		end
		unless(Dir.exists?(Configuration::DownloadsDir))
			Dir.mkdir(Configuration::DownloadsDir)
		end
		unless(Dir.exists?(Configuration::CacheDir))
			Dir.mkdir(Configuration::CacheDir)
		end
	end
end
