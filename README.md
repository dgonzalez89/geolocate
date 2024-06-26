# README

Geolocation API: Takes JSON body and searches for ip address if not present tries the same with url.

Things you may want to cover:

* 1- Build Image
> docker-compose build

* 2- Run Image
> docker-compose run

* 3- Run Tests
> docker-compose exec api bin/rails spec

### How to use the API via Postman
> - The project contains Postman collection [Geolocation.postman_collection.json](docs%2FGeolocation.postman_collection.json) import into your **Postman** application
> - the collection contains request for INDEX, SHOW, CREATE, DELETE with JSON body as ` { "location": { "ip_address": "1.1.1.1", "url": "http://www.google.com" } }`
> - SHOW and DELETE will take the param ID but if not found it will search the body for **ip addres** and if not present then search by **url**.
> - Successful responses will return the found JSON if so.
![success.png](docs%2Fsuccess.png)
> - Failed responses will return a message with the description of the error.
![error.png](docs%2Ferror.png)

### Geocoder
> - Using the geocoder gem we can change the ip provider easy as changing two configuration lines the **GEOLOCATION_PROVIDER_API_KEY** env var with the api key of the service and the geocoder initializer setting  **ip_lookup** currently using the **ipinfo_io** service.

> - My ip info api key is available for local testing on the docker-compose.yml file under **GEOLOCATION_PROVIDER_API_KEY**

### API Endpoints
>   - **create** `POST /locations`
>   - **show** `GET /locations/$ID` Also receives JSON body with ip address and/or url 
>   - **delete** `DELETE /locations/$ID`  Also receives JSON body with ip address and/or url
>   - **index** `GET /locations`







