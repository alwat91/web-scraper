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
  # contact
  company["name"] = content.at_css("[itemprop=name]").text
  company["website"] = content.at_css("[itemprop=url]").text
  company["phone"] = content.css("[itemprop=telephone] span")[0].text
  company["address_1"] = content.at_css("[itemprop=streetAddress]").text
  company["city"] = content.at_css("[itemprop=addressLocality]").text
  company["state"] = content.at_css("[itemprop=addressRegion]").text
  company["zip"] = content.at_css("[itemprop=postalCode]").text

  puts company["zip"]
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
