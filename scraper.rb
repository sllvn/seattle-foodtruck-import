require 'nokogiri'
require 'faraday'
require 'json'
require 'sanitize'
require 'pry'

doc = Nokogiri::HTML.parse(Faraday.get('http://www.seattlefoodtruck.com/index.php/trucks/').body)
days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

# scrape listing page
trucks = doc.css('#inner table tr').select do |tr|
  tr.css('td')[0].text.chop != ''
end.map do |tr|
  {
    name: tr.css('td')[0].text, 
    url: tr.css('a').first.attributes['href'].value,
    food_type: tr.css('td')[1].text
  }
end

# scrape individual pages
trucks[0..5].each do |truck|
  next unless truck[:url][0..3] == 'http'
  truck[:schedule] = {}
  puts "scraping truck: #{truck[:name]}"

  doc = Nokogiri::HTML.parse(Faraday.get(truck[:url]).body)
  tds = doc.css('#inner table')[1].css('td')
  tds.each_with_index do |td, i|
    days_of_week.each do |day|
      if td.text.index(day)
        truck[:schedule][day.downcase.to_sym] = Sanitize.clean(tds[i+1].to_s).gsub(/\n/, '').strip
      end
    end
  end
end

# serialize trucks to yaml
file = File.open("data/trucks_#{Time.new.strftime('%Y%m%d')}.json", 'w')
file.write trucks.to_json
file.close

