require 'json'
require 'pry'
require_relative './lib/google_geocoder'

file = File.open('data/locations.json', 'r+')
locations = JSON.parse(file.read)

locations.each do |location|
  next if !location['cleaned_location'] or location['lat']

  begin
    encoded_address = GoogleGeocoder.encode(location['cleaned_location'].gsub(/&/, 'and'))
    location.merge! encoded_address
    location['error'] = '' if location['error'] == 'error when geocoding'
  rescue BadNumberOfResults
    puts "problem with #{location['cleaned_location']}"
    location['error'] ||= ' '
    location['error'] = "#{location['error']} error when geocoding".strip
    empty_hash = Hash[*%w[lat lng formatted_address].map { |x| [x, nil] }.flatten ]
    location.merge! empty_hash
  end
end

file.write JSON.pretty_generate(locations)

