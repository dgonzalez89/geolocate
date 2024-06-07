class GeolocationHandling::Error 
    class InvalidParameters < StandardError
        def message
            "Invalid parameters"
        end
    end

    class LocationNotFound < StandardError
        def message
            "Ip address or url could not be geolocated"
        end
    end

    class DataNotFound < StandardError
        def message
            "Location was not found"
        end
    end
end