import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Third screen: map with LIVE location.
class LastScreen extends StatefulWidget {
  const LastScreen({super.key});

  @override
  State<LastScreen> createState() => _LastScreenState();
}

class _LastScreenState extends State<LastScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _sub;

  LatLng? _current; // live location
  bool _follow = true; // map live location ke saath move kare
  bool _mapReady = false;
  String? _error;
  final double _zoom = 17;

  @override
  void initState() {
    super.initState();
    _startLive();
  }

  Future<void> _startLive() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (mounted) setState(() => _error = 'Phone ka Location (GPS) ON karo');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _error = 'Location permission allow karo (Settings me)');
      }
      return;
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 5 meter chalne par update
      ),
    ).listen((pos) {
      if (!mounted) return;
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _current = point;
        _error = null;
      });
      if (_follow && _mapReady) {
        _mapController.move(point, _zoom);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(20.5937, 78.9629),
              initialZoom: 5,
              onMapReady: () {
                _mapReady = true;
                if (_current != null) _mapController.move(_current!, _zoom);
              },
              onPositionChanged: (camera, hasGesture) {
                // user ne map haath se hilaya to follow band
                if (hasGesture && _follow) setState(() => _follow = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.map_app', // <- apna package name
              ),
              if (_current != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _current!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Color(0x55000000), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // error / loading message
          if (_error != null || _current == null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (_error == null)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_error ?? 'Live location dhoondh rahe hain...'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // lat / lng card
          if (_current != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Lat: ${_current!.latitude.toStringAsFixed(6)}\n'
                        'Lng: ${_current!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        onPressed: () {
          if (_current != null) {
            setState(() => _follow = true);
            _mapController.move(_current!, _zoom);
          }
        },
        child: Icon(_follow ? Icons.my_location : Icons.location_searching),
      ),
    );
  }
}

