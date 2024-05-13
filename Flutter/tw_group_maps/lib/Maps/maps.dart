// ignore_for_file: library_private_types_in_public_api, avoid_print, camel_case_types, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng _markerPositionAPI = const LatLng(0.0, 0.0);
  LatLng _markerPosition = const LatLng(0.0, 0.0);
  LatLng _currentPosition = const LatLng(0.0, 0.0); // Inicialmente en el mar.
  bool _visiblePosition = false;
  String _region = '';
  String _comuna = '';
  String _direccion = '';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {

    await _getCurrentLocation();
    final CameraPosition initialCameraPosition = CameraPosition(
      target: _currentPosition,
      zoom: 14.0,
    );
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(initialCameraPosition));

    await _getLastLocationAPI();
  }

  Future<void> _getLastLocationAPI() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(
        Uri.parse('http://192.168.0.28:8000/api/address/index'),
        headers: headers,
      );
      print('Conusltando ubicacion');
      if (response.statusCode == 200) {
        var data = convert.jsonDecode(response.body);
        double lat = double.parse(data['latitude']);
        double lng = double.parse(data['longitude']);
        _getAddressFromLatLng(LatLng(lat, lng));
        setState(() {
          _markerPositionAPI = LatLng(lat, lng);
        });
      } else {
        print('Error al obtener la ubicación inicial: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener la ubicación inicial: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission == PermissionStatus.granted) {
      _getCurrentLocation();
    } else {
      print("Permiso denegado para el usuario.");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _region = placemark.administrativeArea ?? '';
          _comuna = placemark.locality ?? '';
          _direccion = placemark.street ?? '';
        });
      }
    } catch (e) {
      print("Error getting address from coordinates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(42, 198, 82, 1), width: 2),
              ),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('api_marker'),
                    position: _markerPositionAPI,
                  ),
                  Marker(
                    markerId: const MarkerId('current_marker'),
                    position: _markerPosition,
                    visible: _visiblePosition
                  ),
                },
                onTap: (LatLng latLng) {
                  setState(() {
                    _markerPosition = latLng;
                    _visiblePosition = true;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _saveLocationAPI(),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar ubicación marcada'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(42, 198, 82, 1)),
                    iconColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 1)),
                    foregroundColor: MaterialStateProperty.all(Colors.white), // Color del texto
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _goToMarkerCurrent,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Ir al nuevo marcador'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(42, 198, 82, 1)),
                    iconColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 1)),
                    foregroundColor: MaterialStateProperty.all(Colors.white), // Color del texto
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _goToMarkerApi,
                  icon: const Icon(Icons.location_pin),
                  label: const Text('Ir a mi última ubicación guardada'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(42, 198, 82, 1)),
                    iconColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 1)),
                    foregroundColor: MaterialStateProperty.all(Colors.white), // Color del texto
                  ),
                ),
                
                const Text('Ultima ubicacion guardada'),
                Text('Región: $_region'),
                Text('Comuna: $_comuna'),
                Text('Dirección: $_direccion'),
                
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(229, 253, 235, 1)),
                    iconColor: MaterialStateProperty.all(const Color.fromRGBO(229, 253, 235, 1)),
                    foregroundColor: MaterialStateProperty.all(const Color.fromRGBO(42, 198, 82, 1)), // Color del texto
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToMarkerApi() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newLatLng(_markerPositionAPI));
  }

  Future<void> _goToMarkerCurrent() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newLatLng(_markerPosition));
  }

  Future<void> _saveLocationAPI() async {{
    final latitude = _markerPosition.latitude.toString();
    final longitude = _markerPosition.longitude.toString();
    
    List<Placemark> placemarks = await placemarkFromCoordinates(double.parse(latitude), double.parse(longitude));
    var region = '';
    var municipality = '';
    var address = '';
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      region = placemark.administrativeArea ?? '';
      municipality = placemark.subAdministrativeArea ?? '';
      address = placemark.street ?? '';
    }
    if (latitude.isEmpty || longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, marca una ubicacion'),
      ));
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      print('Guardando ubicacion');
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('http://192.168.0.28:8000/api/address/store'),
        headers: headers,
        body: {'latitude': latitude, 'longitude': longitude, 'region':region , 'municipality': municipality, 'address': address},
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        if(jsonResponse['status'] == true){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message']),
            ),
          );
          _getLastLocationAPI();
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al retornar respuesta: ${response.reasonPhrase}'),
        ));
        
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error de conexión'),
      ));
    }
  }}

  Future<void> _logout() async {{

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      print('Cerrando sesión');
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('http://192.168.0.28:8000/api/auth/logout'),
        headers: headers
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        
        if(jsonResponse['status'] == true){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message']),
            ),
          );
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Navigator.pushReplacementNamed(context, '/login');

        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al retornar respuesta: ${response.reasonPhrase}'),
        ));
        
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error de conexión'),
      ));
    }
  }}
  
}
