require 'faraday'
require 'json'

class GoogleGeocoder
  def self.encode(address)
    url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=#{address}"
    response = Faraday.get(url)
    doc = JSON.parse(response.body)

    raise BadNumberOfResults if doc['results'].length != 1

    location = doc['results'].first['geometry']['location']

    {
      lat: location['lat'],
      lng: location['lng'],
      formatted_address: doc['results'].first['formatted_address']
    }
  end
end

class BadNumberOfResults < Exception; end

