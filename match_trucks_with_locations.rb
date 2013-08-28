require 'json'
require 'pry'
require_relative './lib/location_cleaner'

date = '20130826'

trucks = JSON.parse(File.read("data/trucks_#{date}.json"))
locations = JSON.parse(File.read('data/locations.json'))

trucks.each do |truck|
  unless truck['schedule']
    puts "missing schedule for: #{truck['name']}"
    next
  end
  truck['schedule'].each do |k, v|
    location = locations.find { |l| v == l['original'] }
    if location
      truck['schedule'][k] = location
    else
      puts "bad location lookup for: #{truck['name']}, #{k}"
    end
  end
end

file = File.open("data/geocoded_trucks_#{date}.json", 'w+')
file.write JSON.pretty_generate(trucks)

