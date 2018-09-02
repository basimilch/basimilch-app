# Load the Rails application.
require_relative 'application'

# Automatically require all extension ruby files in lib folder.
# SOURCE: http://stackoverflow.com/a/735458
Dir[Rails.root.join('lib', '*_extensions.rb')].each do |file|
  puts "Requiring #{file}..."
  require file
end.count.tap do |c|
  puts "#{c} #{'file'.pluralize(c)} successfully loaded." if c.pos?
end

# Initialize the Rails application.
Rails.application.initialize!
