require './helper_methods.rb'

File.open('../data/result.csv', 'w') {|file| file.truncate(1) }

Dir.foreach('../pages') do |file|
  next if file == '.' or file == '..'
  content = open_file("../pages/#{file}")
  content = parse_content(content)
  content = double_check(content)
  build_file(content)
end
