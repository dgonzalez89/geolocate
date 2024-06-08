require "rails_helper"

describe 'Locations API', type: :request do
 
  let!(:location) { create(:location) }
  let(:stub_result) { JSON.parse(location.to_json) }
  let(:stub_location) { double(call: stub_result) } 
  let(:location_not_found) { GeolocationHandling::Error::LocationNotFound.new.message }
  let(:data_not_found) { GeolocationHandling::Error::DataNotFound.new.message } 

  describe 'GET /locations' do
    it 'returns a list of locations' do
      get '/locations'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first['ip_address']).to eq(location.ip_address)
    end
  end

  describe 'GET /locations/:id' do
    let(:request) do
       get "/locations/#{id}", params: params
    end
    let(:params) {{}}
    let(:id) { '1' } 

    before do
      allow(GeolocateMe::FetchData).to receive(:new).and_return(stub_location)
      allow(stub_location).to receive(:call).and_return(stub_result)
    end

    it 'returns a specific location' do
      request
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['ip_address']).to eq(location.ip_address)
    end

    context 'Using ip address as parameter' do
      let(:params) { { location: { ip_address: location.ip_address } } }
      let(:id) { 'x' } 
      it 'returns a specific location' do
        request
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['ip_address']).to eq(location.ip_address)
      end

      context 'geocoder fails to find the location' do
        it 'returns a specific location' do
          allow(stub_location).to receive(:call).and_return(nil)
          request
          expect(response).to have_http_status(500)
          expect(response.body).to eq( {"message": data_not_found}.to_json )
        end
      end
    end
  end

  describe 'POST /locations' do
    before do
      allow(GeolocateMe::FetchData).to receive(:new).and_return(stub_location)
      allow(stub_location).to receive(:call).and_return(stub_result)
    end
    it 'creates a new location' do
      post '/locations', params: { location: { ip_address: '192.168.1.1' } }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['ip_address']).to eq(Location.last.ip_address)
    end

    context 'geocoder fails to find the location' do
      it 'returns a specific location' do
        allow(stub_location).to receive(:call).and_return(nil)
        post '/locations', params: { location: { ip_address: '192.168.1.1' } }
        expect(response).to have_http_status(500)
        expect(response.body).to eq( {"message": location_not_found}.to_json )
      end
    end
  end

  describe 'DELETE /locations/:id' do
    it 'deletes a specific location' do
      delete '/locations/1'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['ip_address']).to eq( '192.168.0.1' )
    end
  end
end