require 'nokogiri'
require 'csv'
require 'net/http'
require 'open-uri'


def parse_uris
  sitemap = Nokogiri::XML(File.open("sitemap.xml"))
  uris = sitemap.css("loc")

  CSV.open('urls.csv', 'wb', :write_headers=> true, :headers => ["mcr_uri"]) do |file|
    uris.each do |uri|
      file << [uri.to_s[5..-7]]
    end
  end
end

def get_content
  CSV.foreach('urls.csv') do |uri|
    content = Nokogiri::HTML(open(uri[0], "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"))
    build_file(parse_content(content))
    sleep_time = rand(30..60)
    sleep(sleep_time)
  end
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
  # Mover details (full table)
  company["mover_details"] = content.css("#mover_details_info").to_s
  # License info (full table)
  company["license_info"] = content.css("#license_table").to_s
  puts company
  company
end

def open_file(file)
  File.open(file) { |f| Nokogiri::XML(f) }
end

def build_file(content)
  CSV.open('../data/result.csv', 'w', :write_headers=> true, :headers => ["name","website","phone","address_1","city","state","zip","has_in_state","has_out_state","has_full_service","has_moving_labor","has_packing_services","has_containers","has_agent","has_art_antiques","has_auto_transport","has_broker","has_carrier_broker","has_commercial_moves","has_corporate_reloc","has_govt","has_industrial_movers","has_dod_cert","has_pianos","has_safes","mover_details","license_info"]) do |file|
    file << content
  end
end

build_file(["blah"])
# content = get_content('http://www.movingcompanyreviews.com/AL/Birmingham/a-wise-move-inc-57486')
# content = open_file("sample1.html")
# parsed_content = parse_content(content)
# build_file(parsed_content)
# content = open_file("sample2.html")
# parse_content(content)
# content = open_file("sample3.html")
# parse_content(content)
# content = open_file("sample4.html")
# parse_content(content)
# content = open_file("sample5.html")
# parse_content(content)
