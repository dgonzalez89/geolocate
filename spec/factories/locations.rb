FactoryBot.define do
    factory :location do
        ip_address { '192.168.0.1' }
        city { 'Panama' }
        country { 'PA' }
        timezone { 'America/Panama' }
    end
end