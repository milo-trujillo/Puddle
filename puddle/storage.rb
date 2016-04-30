require_relative "configuration"

=begin
	This module does things.
	Cool things.
=end

module Storage

	# returns an array of files with the specified tag if the tag is valid
	def self.findfiles(tag)
		# tags should be alphanumeric, and should not be '.' or '..'
		# if these conditions are met, we iterate over the files that contain the tag
		if(tag =~ \A[\w]+\z)
			# create a new array to return
			arr = Array.new
			Dir.glob(Configuation::DataDir + '*' + tag + '*') do |myfile|
				# this should create an array of all the files that contain the tag requested
				str = myfile
				arr.push str 
			end
			return arr
		end
		else # if the tag conditions aren't met
			return nil
		end
	end


end
