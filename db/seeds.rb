require 'json'

trips = JSON.parse(File.read('db/seeds/trips.json'))

trips['trips'].each do |trip|
  Trip.create!(
    name: trip['name'],
    image_url: trip['image'],
    short_description: trip['description'],
    long_description: trip['long_description'],
    rating: trip['rating']
  )
end

puts "Seeded #{Trip.count} trips successfully"
