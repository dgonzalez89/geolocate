# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


Location.create!([{
  ip_address: "192.168.0.1",
  country: "Panama",
  timezone: "America/Panama",
  city: 'Panama'
},
{
    ip_address: "192.168.0.2",
    country: "Costa Rica",
    timezone: "America/Costa Rica",
    city: 'San Jose'
},
{
    ip_address: "192.168.0.3",
    country: "United States",
    timezone: "America/US",
    city: 'Miami'
}])