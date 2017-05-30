require 'nokogiri'
require 'csv'
require 'uri'
require './helper_methods.rb'

File.open('../data/result.csv', 'w') {|file| file.truncate(1) }

Dir.foreach('../pages') do |file|
  next if file == '.' or file == '..'
  content = open_file("../pages/#{file}")
  next if !georgia?(content)
  content = parse_content(content)
  content = double_check(content)
  build_file(content)
end
