class LocationCleaner
  def self.clean(location)
    #@known_locations = ['Queen Anne', 'South Lake Union', 'Pioneer Square', 'Issaquah', 'Des Moines', 'Greenwood', 'Bellevue', 'Downtown Seattle', 'Magnolia', 'SoDo', 'Renton', 'Edmonds', 'Central District', 'Columbia City', 'Belltown', 'Redmond', 'Kirkland', 'Kent', 'West Seattle', 'Capitol Hill', 'Tukwila', 'Wallingford', 'Mercer Island', 'Georgetown', 'Ballard', 'Port Orchard', 'Sammamish', 'Beacon Hill', 'Fremont', 'Federal Way', 'International District', 'SLU', 'Maple Valley', 'Tacoma', 'Everett', 'Pacific', 'Interbay']
    match = location.match(/(.*?)(\d{1,2}:?\d*\s*(am|pm)|noon)/)
    clean_location = match ? match[1].strip.chomp(',') : location
    time = location[clean_location.length+1..-1].strip if match
    #@known_locations.each do |known|
    #  if clean_location.downcase.start_with? known.downcase
    #    clean_location = clean_location[known.length..-1].strip + ', ' + known + ', seattle, wa'
    #  end
    #end
    {
      original: location,
      location: clean_location,
      time: time
    }
  end
end
