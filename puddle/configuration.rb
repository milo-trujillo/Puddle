module Configuration
	Base = File.dirname(__FILE__)
	PrivateFolder = Base + "/private"

	# For network configuration
	Port = 7924 # Swag
	
	# This is for the storage module
	DataDir = PrivateFolder + "/data"
	DownloadsDir = PrivateFolder + "/downloads"
	CacheDir = PrivateFolder + "/cache"
end
