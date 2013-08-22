require 'nokogiri'
require 'faraday'
require 'json'
require 'sanitize'
require 'pry'

class FoodTruckScraper
  attr_accessor :trucks

  def initialize(url)
    puts 'beginning scrape'
    @doc = Nokogiri::HTML.parse(Faraday.get(url).body)
    @days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    @links = %w[Facebook Twitter Website]
  end

  def scrape_list
    @trucks = @doc.css('#inner table tr').select do |tr|
      tr.css('td')[0].text.chop != ''
    end.map do |tr|
      {
        name: tr.css('td')[0].text, 
        url: tr.css('a').first.attributes['href'].value,
        food_type: tr.css('td')[1].text
      }
    end
  end

  def scrape_trucks
    @trucks.each do |truck|
      next unless truck[:url][0..3] == 'http'
      truck[:schedule], truck[:links] = {}, {}
      puts "scraping truck: #{truck[:name]}"

      doc = Nokogiri::HTML.parse(Faraday.get(truck[:url]).body)
      tds = doc.css('#inner table').css('td')
      tds.each_with_index do |td, i|
        if td.text.index('Payment')
          truck[:payment] = Sanitize.clean(tds[i+1].to_s).gsub(/\n/, '').strip
        end
        if td.text.index('Description')
          truck[:description] = Sanitize.clean(tds[i+1].to_s).gsub(/\n/, '').strip
        end
        @days_of_week.each do |day|
          if td.text.index(day)
            truck[:schedule][day.downcase.to_sym] = Sanitize.clean(tds[i+1].to_s).gsub(/\n/, '').strip
          end
        end
        @links.each do |link|
          if td.text.index(link)
            truck[:links][link.downcase.to_sym] = Sanitize.clean(tds[i+1].to_s).gsub(/\n/, '').strip
          end
        end
      end
    end
  end
end

scraper = FoodTruckScraper.new('http://www.seattlefoodtruck.com/index.php/trucks/')
scraper.scrape_list
scraper.scrape_trucks

file = File.open("data/trucks_#{Time.new.strftime('%Y%m%d')}.json", 'w')
file.write JSON.pretty_generate(scraper.trucks)
file.close

