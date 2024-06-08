class LocationsController < ApplicationController
    include GeolocateMe

    skip_before_action :verify_authenticity_token  

    def index
        render json: Location.all.order(:id).to_json, status: 200
    end

    def show
        if params[:id]
            location = Location.find_by(id: params[:id])
            unless location
                ip_address = parse_ip_address
                url = parse_url

                if(ip_address || url)
                    result = geocoder_client(ip_address, url).call
                    location = Location.find_by(ip_address: result['ip_address']) if result
                end
            end

            if location
                render json: location.to_json, status: :ok
            else
                render json: { "message": data_not_found }, status: 500
            end
        else
            render json: { "message": invalid_params_message }, status: 400
        end
    end

    def create
        ip_address = parse_ip_address
        url = parse_url

        if ip_address || url
            result = geocoder_client(ip_address, url).call
            if result
                Location.where(ip_address: result['ip_address']).first_or_create(result)
                render json: result.to_json, status: :created 
            else
                location_not_found
                render json: { "message": location_not_found }, status: 500
            end
        else
            render json: { "message": invalid_params_message }, status: 400
        end
    end

    def destroy
        ip_address = parse_ip_address
        url = parse_url

        if !!(ip_address || url || params[:id])
            location = Location.find_by(id: params[:id])
            unless location
              result = geocoder_client(ip_address, url).call
              location = Location.find_by(ip_address: result['ip_address']).destroy if result
            end

            if location 
                deleted_ip_address = location.ip_address
                location.destroy
                render json: {ip_address: deleted_ip_address}.to_json, status: :ok
            else
                render json: { "message": data_not_found }, status: 500
            end
        else
            render json: { "message": invalid_params_message }, status: 400 
        end
    end

    private

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

    def invalid_params_message
        GeolocationHandling::Error::InvalidParameters.new.message
    end

    def location_not_found
        GeolocationHandling::Error::LocationNotFound.new.message
    end

    def data_not_found
        GeolocationHandling::Error::DataNotFound.new.message
    end
end
