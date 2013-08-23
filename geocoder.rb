require 'json'
require 'pry'
require 'google_places'

require_relative './lib/location_cleaner'

trucks = JSON.parse(File.read('data/trucks_20130822.json'))

# get unique locations
locations = trucks.map do |truck|
  truck['schedule'].values if truck['schedule']
end.flatten.uniq.compact

cleaned = locations.map do |location|
  LocationCleaner.clean(location)
end

# geocode all the unique locations, reporting errors if found
errors = []
cleaned[0..20].each_with_index do |location, index|
  # TODO: actual geocoding
  begin
    geocoded = GoogleGeocoder.encode(location[:location])
    location[:latlng] = { lat: geocoded[:lat], lng: geocoded[:lng] }
    location[:cleaned_address] = geocoded[:formatted_address]
  rescue BadNumberOfResults
    puts "error geocoding: #{location[:location]}"
    errors << index
  end
end

# map geocoded latlng back to truck schedules
trucks.each do |truck|
  next unless truck['schedule']
  truck['schedule'].each do |day, location|
    cleaned.each do |cl|
      if cl[:original] == location
        truck['schedule'][day] = cl
        next
      end
    end
  end
end

