
# autoload everything in the autoload directory
Dir["#{File.dirname(__FILE__)}/autoload/*.rb"].each { |file| load_from_file(file) }