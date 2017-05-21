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

  # Services
  company_services = content.css(".company-services").css(".features").to_s
  company["has_in_state"] = company_services.include?("In state")
  company["has_out_state"] = company_services.include?("Out of state")
  company["has_full_service"] = company_services.include?("Full-Service Move")
  company["has_moving_labor"] = company_services.include?("Moving Labor")
  company["has_packing_services"] = company_services.include?("Packing Services")
  company["has_containers"] = company_services.include?("Portable Storage Containers")
  company["has_agent"] = company_services.include?("Agent")
  company["has_art_antiques"] = company_services.include?("Art")
  company["has_auto_transport"] = company_services.include?("Auto Transport")
  company["has_broker"] = company_services.include?("Broker")
  company["has_carrier_broker"] = company_services.include?("Carrier/Broker")
  company["has_commercial_moves"] = company_services.include?("Commercial/Business Moves")
  company["has_corporate_reloc"] = company_services.include?("Corporate Relocation")
  company["has_govt"] = company_services.include?("Government")
  company["has_industrial_movers"] = company_services.include?("Industrial Movers")
  company["has_dod_cert"] = company_services.include?("Military/DOD Certified")
  company["has_pianos"] = company_services.include?("Pianos")
  company["has_safes"] = company_services.include?("Safes")

  puts company
end

def open_file(file)
  File.open(file) { |f| Nokogiri::XML(f) }
end

# content = get_content('http://www.movingcompanyreviews.com/AL/Birmingham/a-wise-move-inc-57486')
content = open_file("sample1.html")
parse_content(content)
# content = open_file("sample2.html")
# parse_content(content)
# content = open_file("sample3.html")
# parse_content(content)
# content = open_file("sample4.html")
# parse_content(content)
# content = open_file("sample5.html")
# parse_content(content)
