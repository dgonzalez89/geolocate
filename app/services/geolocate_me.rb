module GeolocateMe
    class FetchData
        def initialize(ip_address:, url:)
            @ip_address = ip_address
            @url = url
        end

        def call
          if @ip_address
            return parseData(Geocoder.search(@ip_address).first.data)
          elsif @url
            begin
              host = URI.parse(@url).host
              ip_from_url = Resolv.getaddress host
              parseData(Geocoder.search(ip_from_url).first.data)
            end
          end
        rescue Resolv::ResolvError
          raise GeolocationHandling::Error::DataNotFound.new
        end

        private

        def parseData(data)
          data = data.except("postal", "loc", "org", "region", "hostname", "anycast")
          return nil unless data.key?('city') && data.key?('country') && data.key?('timezone')

          data.map{ |key, val| key == 'ip' ? ['ip_address', val] : [key,val]  }.to_h
        end
    end
end