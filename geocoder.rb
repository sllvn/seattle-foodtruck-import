require 'json'
require 'pry'

file = File.open('data/locations.json', 'r+')
trucks = JSON.parse(file.read)

trucks.each do |truck|
  binding.pry
end

