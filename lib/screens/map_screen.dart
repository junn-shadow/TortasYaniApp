import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  LatLng _initialLocation = const LatLng(-16.4090, -71.5375); // Arequipa
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _initialLocation;
        _loadingLocation = false;
      });

      _mapController.move(_initialLocation, 16);
    } catch (e) {
      setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 17, 41),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1035),
        title: const Text(
          "Selecciona tu dirección",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.tortasyani.app",
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF07070),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF07070).withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 22),
                          ),
                          const Text("📍", style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // LOADING
          if (_loadingLocation)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFF07070)),
                    SizedBox(height: 16),
                    Text(
                      "Obteniendo tu ubicación...",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // INSTRUCCIÓN ARRIBA
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1035).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, color: Color(0xFFF07070), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Toca el mapa para seleccionar tu dirección de entrega",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN MI UBICACIÓN
          Positioned(
            right: 16,
            bottom: 120,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1035),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location, color: Color(0xFFF07070), size: 24),
              ),
            ),
          ),

          // BOTÓN CONFIRMAR
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                if (_selectedLocation != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1035).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFF07070), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, "
                            "Lng: ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _selectedLocation == null
                        ? null
                        : () {
                            final mapsUrl =
                                "https://maps.google.com/?q=${_selectedLocation!.latitude},${_selectedLocation!.longitude}";
                            
                            const distance = Distance();
                            final double meter = distance.as(LengthUnit.Meter, _initialLocation, _selectedLocation!);
                            final double km = meter / 1000.0;
                            
                            double cost = 5.0;
                            if (km > 3.0) {
                              cost += (km - 3.0) * 1.5;
                            }
                            
                            Navigator.pop(context, {
                              'url': mapsUrl,
                              'distance': km,
                              'cost': cost
                            });
                          },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      "Confirmar ubicación",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF07070),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
