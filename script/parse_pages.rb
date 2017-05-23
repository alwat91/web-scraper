require 'nokogiri'
require 'csv'
require 'uri'

def open_file(path)
  Nokogiri::XML(File.open(path))
end

def parse_content(content)
  company = Hash.new
  # contact
  if content.at_css("[itemprop=name]") == nil
    company["name"] = ""
  else
    company["name"] = content.at_css("[itemprop=name]").text
  end
  if content.at_css("[itemprop=url]") == nil
    company["website"] = ""
  else
    company["website"] = content.at_css("[itemprop=url]").to_s.scan(URI.regexp)[0][3]
  end
  if content.at_css("[itemprop=telephone] span") == nil
    company["phone"] = ""
  else
    company["phone"] = content.css("[itemprop=telephone] span")[0].text
  end
  if content.at_css("[itemprop=streetAddress]") == nil
    company["address_1"] = ""
  else
    company["address_1"] = content.at_css("[itemprop=streetAddress]").text
  end
  if content.at_css("[itemprop=addressLocality]") == nil
    company["city"] = ""
  else
    company["city"] = content.at_css("[itemprop=addressLocality]").text
  end
  if content.at_css("[itemprop=addressRegion]") == nil
    company["state"] = ""
  else
    company["state"] = content.at_css("[itemprop=addressRegion]").text
  end
  if content.at_css("[itemprop=postalCode]") == nil
    company["zip"] = ""
  else
    company["zip"] = content.at_css("[itemprop=postalCode]").text
  end

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
  # Mover details
  mover_details = content.css("#mover_details_info").css("tr")

  mover_details.each do |row|
     name = row.css("td:first-child").text
     quantity = row.css("td:nth-child(2)").text

     if name.include?("Trucks")
       company["num_trucks"] = quantity
     else
       company["num_trucks"] = ""
     end

     if name.include?("Warehouse Size")
       company["warehouse_size"] = quantity
     else
       company["warehouse_size"] = ""
     end

     if name.include?("Business Type")
       company["business_type"] = quantity
     else
       company["business_type"] = ""
     end

     if name.include?("In Business Since")
       company["since"] = quantity
     else
       company["since"] = ""
     end

     if name.include?("Better Business Bureau")
       company["bbb_link"] = "http://www.bbb.org#{row.css("td:nth-child(2)").to_s.scan(URI.regexp)[0][6]}"
     else
       company["bbb_link"] = ""
     end
  end
  # if mover_details.to_s.include?("Trucks")
  #   company["num_trucks"] = mover_details.css("tr:first-child td:nth-child(2)").text
  # else
  #   company["num_trucks"] = ""
  # end
  #
  # if mover_details.to_s.include?("Warehouse Size")
  #   puts mover_details.css("tr:nth-child(2) td:nth-child(2)").text
  # end
  # content.css("#mover_details_info").css("tr td").each_with_index do |el, i|
  #   if el.text == "Number of Trucks"
  #     puts content.css("#mover_details_info")
  #   end
  # end
  license_info = content.css("#license_table").css("tr")

  license_info.each do |row|
    info = row.css("td:nth-child(3)").text

    if row.to_s.include?("usdot_row")
      company["dot_info"] = info
    else
      company["dot_info"] = ""
    end

    if row.to_s.include?("state_license_row")
      company["state_license_info"] = info
    else
      company["state_license_info"] = ""
    end

    if row.to_s.include?("state_association_row")
      company["state_assoc_info"] = info
    else
      company["state_assoc_info"] = ""
    end
  end


  # # Mover details (full table)
  # company["mover_details"] = content.css("#mover_details_info").to_s
  # License info (full table)
  # company["license_info"] = content.css("#license_table").to_s

  company
end

def build_file(content)
  dupe = false
  CSV.foreach('../data/result.csv', headers:true) do |row|
    if row['address_1'] == content['address_1'] and row['name'] == content['name']
      dupe = true
      next
    end
  end

  if !dupe
    CSV.open('../data/result.csv', 'a+') do |file|
      file << content.values
    end
  end
end

Dir.foreach('../pages') do |file|
  next if file == '.' or file == '..'
  content = open_file("../pages/#{file}")
  content = parse_content(content)
  build_file(content)
end
