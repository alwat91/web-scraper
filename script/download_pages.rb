require 'open-uri'
require 'csv'

def get_content
  CSV.foreach('../data/urls.csv') do |uri|
    if $. < 520
      next
    end

    puts uri
    open("../pages/page#{$.}.html", 'w') do |file|
      file << open(uri[0], "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36").read
    end
    # content = Nokogiri::HTML(open(uri[0], "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"))
    # build_file(parse_content(content))
    sleep_time = rand(5..10)
    sleep(sleep_time)
  end
end

get_content
