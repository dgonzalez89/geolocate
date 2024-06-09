class LocationsController < ApplicationController
    include GeolocateMe

    skip_before_action :verify_authenticity_token  

    def index
        render json: Location.all.order(:id).to_json, status: 200
    end

    def show
        raise invalid_params unless params[:id]

        location = Location.find_by(id: params[:id])
        if location.nil?
            ip_address = parse_ip_address
            url = parse_url

            if(ip_address || url)
                result = geocoder_client(ip_address, url).call
                location = Location.find_by(ip_address: result['ip_address']) if result
            end
        end

        raise data_not_found unless location
        render json: location.to_json, status: :ok
    rescue => e
        render_error(e)
    end

    def create
        ip_address = parse_ip_address
        url = parse_url
        raise invalid_params unless ip_address || url

        result = geocoder_client(ip_address, url).call
        raise location_not_found unless result

        Location.where(ip_address: result['ip_address']).first_or_create(result)
        render json: result.to_json, status: :created 
    rescue => e
        render_error(e)
    end

    def destroy
        ip_address = parse_ip_address
        url = parse_url

        raise invalid_params unless (ip_address || url || params[:id])

        location = Location.find_by(id: params[:id])
        unless location
            result = geocoder_client(ip_address, url).call
            location = Location.find_by(ip_address: result['ip_address']).destroy if result
        end

        raise data_not_found unless location

        deleted_ip_address = location.ip_address
        location.destroy
        render json: {ip_address: deleted_ip_address}.to_json, status: :ok
    rescue => e
        render_error(e)
    end

    private

    def render_error(e)
        render json: { "message": e.message }, status: 500
    end

    def geocoder_client(ip_address, url)
        FetchData.new( ip_address: ip_address, url: url )
    end

    def parse_ip_address
        return nil unless geolocation_params && geolocation_params[:ip_address]

        geolocation_params[:ip_address] =~ Resolv::IPv4::Regex ? geolocation_params[:ip_address] : nil
    end

    def parse_url
        return nil unless geolocation_params && geolocation_params[:url]

        geolocation_params[:url] =~ URI::regexp ? geolocation_params[:url] : nil
    end

    def geolocation_params
      params.require(:location).permit(:ip_address, :url)
    rescue ActionController::ParameterMissing
    end

    def invalid_params
        GeolocationHandling::Error::InvalidParameters.new
    end

    def location_not_found
        GeolocationHandling::Error::LocationNotFound.new
    end

    def data_not_found
        GeolocationHandling::Error::DataNotFound.new
    end
end
