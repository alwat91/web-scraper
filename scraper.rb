require 'nokogiri'
require 'csv'
require 'net/http'
require 'open-uri'


def parse_uris
  sitemap = Nokogiri::XML(File.open("sitemap.xml"))
  uris = sitemap.css("loc")

  CSV.open('data.csv', 'wb', :write_headers=> true, :headers => ["mcr_uri"]) do |file|
    uris.each do |uri|
      file << [uri.to_s[5..-7]]
    end
  end
end

def get_content(address)
  Nokogiri::HTML(open(address))
end

def parse_content(content)
  company = Hash.new
  # company["name"] = content.at_css("[itemprop=name]").to_s[22..-8]
  company["name"] = content.at_css("[itemprop=name]").text
  company["website"] = content.at_css("[itemprop=url]").text
  # company["website"] = content.at_css("[itemprop=url]").to_s[60..-5]
  # company["address_1"] = content.at_css("[itemprop=streetAddress]").to_s[31..-8]
  company["phone"] = content.css("[itemprop=telephone] span")[0].text

  company["address_1"] = content.at_css("[itemprop=streetAddress]").text

  puts company["phone"]
end

def open_file(file)
  File.open(file) { |f| Nokogiri::XML(f) }
end

# content = get_content('http://www.movingcompanyreviews.com/AL/Birmingham/a-wise-move-inc-57486')
content = open_file("sample1.html")
parse_content(content)
content = open_file("sample2.html")
parse_content(content)
content = open_file("sample3.html")
parse_content(content)
content = open_file("sample4.html")
parse_content(content)
content = open_file("sample5.html")
parse_content(content)
