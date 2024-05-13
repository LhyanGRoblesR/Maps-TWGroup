<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Laravel - Google Maps</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <script src="https://code.jquery.com/jquery-3.4.1.js"></script>
    @vite(['resources/sass/app.scss', 'resources/js/app.js'])
    <style type="text/css">
        #map {
          height: 400px;
        }
    </style>
    <link href="https://api.mapbox.com/mapbox-gl-js/v3.3.0/mapbox-gl.css" rel="stylesheet">
    <script src="https://api.mapbox.com/mapbox-gl-js/v3.3.0/mapbox-gl.js"></script>

</head>

<body>
    <nav class="navbar navbar-expand-md navbar-light bg-white shadow-sm">
        <div class="container">
            <a class="navbar-brand" href="{{ url('/') }}">
                TW Group
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="{{ __('Toggle navigation') }}">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <!-- Left Side Of Navbar -->
                <ul class="navbar-nav me-auto">

                </ul>

                <!-- Right Side Of Navbar -->
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item dropdown">
                        <a id="navbarDropdown" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" v-pre>
                            {{ Auth::user()->name }}
                        </a>

                        <div class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="{{ route('logout') }}"
                                onclick="event.preventDefault();
                                                document.getElementById('logout-form').submit();">
                                {{ __('Logout') }}
                            </a>

                            <form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
                                @csrf
                            </form>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <main class="py-4">
        <div class="container mt-5">
            <div class="row ">
                <div class="col-md-4 row">
                    <div class="col-md-12"><h2>Laravel - Maps</h2>
                    </div>
                    <div class="col-md-12"> <button id="get-last_location-btn" class="btn  w-100" style="background-color: rgba(42, 198, 82, 1); color: white">Ir a ultima ubicación guardada</button></div>

                    <div class="col-md-12">
                        <h5>Ultima ubicacion guardada:</h5>
                        <h5>Region: {{$lastAddress->region}} </h5>
                        <h5>Comuna: {{$lastAddress->municipality}}</h5>
                        <h5>Dirección:{{$lastAddress->address}} </h5>
                    </div>
                    <div class="col-md-12"><button id="get-current_location-btn" class="btn  w-100" style="background-color: rgba(42, 198, 82, 1); color: white">Ir a ubicación actual</button></div>
                    <div class="col-md-12"><button id="get-new_location-btn" class="btn  w-100" style="background-color: rgba(42, 198, 82, 1); color: white">Ir a ubicación marcada</button></div>

                    <div class="col-md-12"><button id="post-new_location-btn" class="btn  w-100" style="background-color: rgba(42, 198, 82, 1); color: white">Guardar ubicacion marcada</button></div>

                </div>
                <div class="col-md-8">
                    <div id="map"></div>

                    {{-- <x-maps-leaflet
                        :centerPoint="['lat' => -16.451621468541763, 'long' => -71.53688214719296]"
                        :zoomLevel="16"
                        :markers="[['lat' => -16.451621468541763, 'long' => -71.53688214719296]]"
                        ></x-maps-leaflet> --}}

                </div>
            </div>

        </div>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", () => {
        getCurrentLocation()
        var marker = null;
        var currentMarker = null;
        var newMarker = null;
        var g_lngLat = [];
        let address = '';
        let region = '';
        let municipality = '';
        mapboxgl.accessToken = '{{YOUR_API_KEY}}';
        LongLat = [-71.53688214719296, -16.451621468541763];
        const map = new mapboxgl.Map({
            container: 'map',
            style: 'mapbox://styles/mapbox/streets-v9',
            projection: 'globe', // Display the map as a globe, since satellite-v9 defaults to Mercator
            zoom: 16,
            center: [-71.53688214719296, -16.451621468541763]
        });

        map.addControl(new mapboxgl.NavigationControl());
        map.scrollZoom.disable();

        map.on('style.load', () => {
            map.setFog({}); // Set the default atmosphere style
        });

        // The following values can be changed to control rotation speed:

        // At low zooms, complete a revolution every two minutes.
        const secondsPerRevolution = 240;
        // Above zoom level 5, do not rotate.
        const maxSpinZoom = 5;
        // Rotate at intermediate speeds between zoom levels 3 and 5.
        const slowSpinZoom = 3;

        let userInteracting = false;
        const spinEnabled = true;

        function spinGlobe() {
            const zoom = map.getZoom();
            if (spinEnabled && !userInteracting && zoom < maxSpinZoom) {
                let distancePerSecond = 360 / secondsPerRevolution;
                if (zoom > slowSpinZoom) {
                    // Slow spinning at higher zooms
                    const zoomDif =
                        (maxSpinZoom - zoom) / (maxSpinZoom - slowSpinZoom);
                    distancePerSecond *= zoomDif;
                }
                const center = map.getCenter();
                center.lng -= distancePerSecond;
                // Smoothly animate the map over one second.
                // When this animation is complete, it calls a 'moveend' event.
                map.easeTo({ center, duration: 1000, easing: (n) => n });
            }
        }

        // Pause spinning on interaction
        map.on('mousedown', () => {
            userInteracting = true;
        });
        map.on('dragstart', () => {
            userInteracting = true;
        });

        // When animation is complete, start spinning if there is no ongoing interaction
        map.on('moveend', () => {
            spinGlobe();
        });

        spinGlobe();

        document.getElementById('get-last_location-btn').addEventListener('click', function() {
            map.setCenter([{{$lastAddress->longitude}}, {{$lastAddress->latitude}}]);
            map.setZoom(16);
        });

        document.getElementById('get-new_location-btn').addEventListener('click', function() {
            console.log([g_lngLat[0], g_lngLat[1]]);

            map.setCenter([g_lngLat[0], g_lngLat[1]]);
            map.setZoom(16);
        });

        document.getElementById('get-current_location-btn').addEventListener('click', function() {
            getCurrentLocation()
        });

        document.getElementById('post-new_location-btn').addEventListener('click', function() {
            postNewLocation();
        });


        function getCurrentLocation(){
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var userLatLng = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude
                    };
                    console.log(userLatLng);

                    // Centra el mapa en la ubicación del usuario
                    map.setCenter(userLatLng);
                    // Ajusta el zoom del mapa según sea necesario
                    map.setZoom(16);

                    // Agrega un marcador en la ubicación del usuario
                    addCurrentMarker([userLatLng.lng, userLatLng.lat]);

                }, function(error) {
                    console.error('Error al obtener la ubicación:', error);
                });
            } else {
                alert('Tu navegador no admite geolocalización.');
            }
        }

        function addCurrentMarker(lngLat) {
            // Elimina el marcador anterior si existe
            if (currentMarker !== null) {
                currentMarker.remove();
            }
            // map.removeLayer('currentMarkerLayer');
            // Crea un nuevo marcador en la posición dada
            map.addLayer({
                'id': 'currentMarkerLayer',
                'type': 'circle',
                'source': {
                    'type': 'geojson',
                    'data': {
                        'type': 'Feature',
                        'properties': {},
                        'geometry': {
                            'type': 'Point',
                            'coordinates': lngLat
                        }
                    }
                },
                'paint': {
                    'circle-radius': 5,
                    'circle-color': '#007bff',
                    'circle-opacity': 0.5
                }
            });
        }

        function addOldMarker(lngLat) {

            new mapboxgl.Marker()
                .setLngLat(lngLat)
                .addTo(map);
        }

        function addNewMarker(lngLat) {
            if (newMarker !== null) {
                newMarker.remove();
            }

            console.log(lngLat);
            g_lngLat = lngLat;

            newMarker = new mapboxgl.Marker()
                .setLngLat(lngLat)
                .addTo(map);
        }

        // Agrega un evento de clic al mapa
        map.on('click', function(event) {
            // Obtiene las coordenadas de longitud y latitud donde se hizo clic
            g_lngLat = [event.lngLat.lng, event.lngLat.lat];
            // Agrega un marcador en la posición donde se hizo clic
            addNewMarker(g_lngLat);
            reverseGeocode(g_lngLat);
        });

        addOldMarker([{{$lastAddress->longitude}}, {{$lastAddress->latitude}}]);

        // Función para realizar la geocodificación inversa
        function reverseGeocode(lngLat) {
            fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/${lngLat[0]},${lngLat[1]}.json?access_token=${mapboxgl.accessToken}`)
                .then(response => response.json())
                .then(data => {
                    // Verifica si hay features en la respuesta
                    if (data.features && data.features.length > 0) {
                        const features = data.features;
                        address = features[0].text;
                        region = features[3].text;
                        municipality = features[2].text;
                        console.log(features);
                        // Muestra la información obtenida
                        console.log('Dirección:', address);
                        console.log('Región:', region);
                        console.log('Comuna:', municipality);
                    } else {
                        console.error('No se encontraron características en la respuesta.');
                    }
                })
                .catch(error => {
                    console.error('Error al realizar la geocodificación inversa:', error);
                });
        }

        function postNewLocation() {
            // URL de tu ruta Laravel
            const url = '/home/store';
            const token = getToken();
            // Datos a enviar en formato JSON
            const data = {
                latitude: g_lngLat[1],
                longitude: g_lngLat[0],
                region: region,
                municipality: municipality,
                address: address,
                _token: getToken() // Si necesitas enviar un token CSRF
            };

            // Configuración de la solicitud
            const options = {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            };

            // Realizar la solicitud
            fetch(url, options)
                .then(response => response.json())
                .then(data => {
                    console.log(data);
                    location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }

        function getToken() {
            const metaTag = document.querySelector('meta[name="csrf-token"]');
            if (metaTag) {
                return metaTag.content;
            } else {
                console.error('No se encontró el meta tag CSRF.');
                return null;
            }
        }

    });

    </script>



</body>
</html>
