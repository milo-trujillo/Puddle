require_relative "configuration"

=begin

	findFiles(tag):
		arguments:
			tag - the tags you want to search for in file names
		returns:
			an array of all the files in the data and cache folders containing the tag in its name

	listCacheFiles()
		returns:
			an array of all file names in the cache directory

	listDataFiles()
		returns:
			an array of all file names in the cache directory

	listDownloadsFiles()
		returns:
			an array of all file names in the cache directory
	
	storeFile(filename, data)
		arguments:
			filename - the name of the file to be saved
			data - the contents of the file to be saved
		returns:
			true if the file was saved, false otherwise

=end

module Storage

	# returns an array of files with the specified tag if the tag is valid
	def self.findFiles(tag)
		# tags should be alphanumeric, and should not be '.' or '..'
		# if these conditions are met, we iterate over the files that contain the tag
		if(tag =~ /\A[\w]+\z/)
			# create a new array to return
			arr = Array.new
			Dir.glob(Configuration::DataDir + '/*' + tag + '*') do |myfile|
				# this should create an array of all the files that contain the tag requested
				str = myfile
				arr.push str 
			end
			Dir.glob(Configuration::CacheDir + '/*' + tag + '*') do |myfile|
				# this should create an array of all the files that contain the tag requested
				str = myfile
				arr.push str 
			end
			return arr
		else # if the tag conditions aren't met
			return []
		end
	end

	# returns an array of all files in the cache
	def self.listCacheFiles()
			# create an array to return
			arr = Array.new
			# iterate through each file
			Dir.glob(Configuration::CacheDir + '/*') do |myfile|
				if(myfile == '.' or myfile == '..')
					# this ensures we don't list current directory or upper directory
					next
				end
				# append filenames to the array
				str = myfile
				str = str.sub(Configuration::CacheDir + '/', '')
				arr.push str
			end
			# return the array
			return arr
	end

	def self.listDataFiles()
			# create an array to return
			arr = Array.new
			# iterate through each file
			Dir.glob(Configuration::DataDir + '/*') do |myfile|
				if(myfile == '.' or myfile == '..')
					# this ensures we don't list current directory or upper directory
					next
				end
				# append filenames to the array
				str = myfile
				str = str.sub(Configuration::DataDir + '/', '')
				arr.push str
			end
			# return the array
			return arr
	end

	def self.listDownloadsFiles()
			# create an array to return
			arr = Array.new
			# iterate through each file
			Dir.glob(Configuration::DownloadsDir + '/*') do |myfile|
				if(myfile == '.' or myfile == '..')
					# this ensures we don't list current directory or upper directory
					next
				end
				# append filenames to the array
				str = myfile
				str = str.sub(Configuration::DownloadsDir + '/', '')
				arr.push str
			end
			# return the array
			return arr
	end

	def self.storeFile(filename, data)
		if(data == nil or filename == nil || data.size == 0 || filename.size == 0)
			return false
		end
		File.write(Configuration::DownloadsDir + "/" + filename, data)
		return true
	end

	def self.cacheFile(filename, data)
		if(data == nil or filename == nil || data.size == 0 || filename.size == 0)
			return false
		end
		File.write(Configuration::CacheDir + "/" + filename, data)
		return true
	end

end
