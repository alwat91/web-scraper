require 'nokogiri'
require 'csv'
require 'uri'

puts "Searching..."

def open_file(path)
  Nokogiri::XML(File.open(path))
end

Dir.foreach('../pages') do |file|
  next if file == '.' or file == '..'
  content = open_file("../pages/#{file}")
  puts content.css("[itemprop=postOfficeBoxNumber]")
end
