require 'json'
require 'pry'

require_relative './location_cleaner'

trucks = JSON.parse(File.read('data/trucks_20130822.json'))

# get unique locations
locations = trucks.map do |truck|
  truck['schedule'].values if truck['schedule']
end.flatten.uniq.compact

cleaned = locations.map do |location|
  LocationCleaner.clean(location)
end

# geocode all the unique locations, reporting errors if found
cleaned.each do |location|
  # TODO: actual geocoding
  location[:latlng] = { lat: '40.7', lng: '-120' }
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

