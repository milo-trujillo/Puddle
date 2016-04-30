module Configuration
	Base = File.dirname(__FILE__)
	PrivateFolder = Base + "/private"
	
	# This is for the storage module
	DataDir = PrivateFolder + "/data"
	DownloadsDir = PrivateFolder + "/downloads"
	CacheDir = PrivateFolder + "/cache"
end
