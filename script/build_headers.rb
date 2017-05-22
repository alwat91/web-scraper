require 'nokogiri'
require 'csv'
require 'uri'

@headers = ["name","website","phone","address_1","city","state","zip","has_in_state","has_out_state","has_full_service","has_moving_labor","has_packing_services","has_containers","has_agent","has_art_antiques","has_auto_transport","has_broker","has_carrier_broker","has_commercial_moves","has_corporate_reloc","has_govt","has_industrial_movers","has_dod_cert","has_pianos","has_safes","mover_details","license_info"]

def open_file(path)
  Nokogiri::XML(File.open(path))
end

def check_details(content)
  content.css("#mover_details_info").css("tr td:first-child").each do |el|
    @headers << el.text unless @headers.include?(el.text)
  end
end

def check_license(content)
   content.xpath("//table[@id='license_table']/tr/@id").each do |el|
     @headers << el.text unless @headers.include?(el.text)
   end
end

Dir.foreach('../pages') do |file|
  next if file == '.' or file == '..'
  content = open_file("../pages/#{file}")

  check_details(content)
end

Dir.foreach('../pages') do |file|
  next if file == '.' or file == '..'
  content = open_file("../pages/#{file}")

  check_license(content)
end

CSV.open('../data/headers.csv', 'w') do |file|
  file << @headers
end
