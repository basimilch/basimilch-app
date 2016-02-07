# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'rails_extensions'

# TODO: Outcomment to automatically require all .rb files in lib/
# SOURCE: http://stackoverflow.com/a/735458
# Dir[File.expand_path(File.join('..', '..', 'lib', '*.rb'), __FILE__)].each do |file|
#   puts "Requiring: #{file}"
#   require file
# end

# Initialize the Rails application.
Rails.application.initialize!
