require 'json'
require 'pry'
require_relative './lib/location_cleaner'

trucks = JSON.parse(File.read('data/trucks_20130826.json'))

# get unique locations
locations = trucks.map do |truck|
  truck['schedule'].values if truck['schedule']
end.flatten.uniq.compact

locations = locations.map do |location|
  LocationCleaner.clean(location)
end

file = File.open('data/locations.json', 'w+')
saved_locations = file.read.empty? ? [] : JSON.parse(file.read)

locations.each do |location|
  found = saved_locations.find { |saved| saved[:original] == location[:original] }
  unless found
    saved_locations << location
  end
end

binding.pry

file.write JSON.pretty_generate(saved_locations)

