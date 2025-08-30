unless City.first
  cities = JSON.parse(Rails.root.join('vendor', 'cities.json').read) # need SAX parsing
  buffer = []
  cities.each do |city|
    next if city['country'] != 'RU'

    buffer << { name: city['name'], latitude: city['lat'], longitude: city['lng'] }
    next if buffer.size < 1_000

    buffer.uniq! { |c| c[:name] }
    City.upsert_all buffer, unique_by: :name
    buffer.clear
  end
  if buffer.any?
    buffer.uniq! { |c| c[:name] }
    City.upsert_all buffer, unique_by: :name
  end
end



