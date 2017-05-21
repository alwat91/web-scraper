require 'nokogiri'
require 'csv'

def parse_uris
  sitemap = Nokogiri::XML(File.open("sitemap.xml"))
  uris = sitemap.css("loc")

  CSV.open('data.csv', 'w') do |file|
    uris.each do |uri|
      file << [uri.to_s[5..-7]]
    end
  end
end

parse_uris
