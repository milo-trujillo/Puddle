module Configuration
	Base = File.dirname(__FILE__)
	PrivateFolder = Base + "/private"
	PublicFolder = Base + "/public"

	# For network configuration
	Port = 7924 # Swag
	NetThreads = 3 # How many threads should idle waiting to send data

	# For the logging system
	LogFile = PrivateFolder + "/log.txt"
	
	# This is for the storage module
	DataDir = PrivateFolder + "/data"
	DownloadsDir = PrivateFolder + "/downloads"
	CacheDir = PrivateFolder + "/cache"
end
