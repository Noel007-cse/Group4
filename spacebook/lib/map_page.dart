import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final String locationName;
  final List<Map<String, dynamic>> allSpaces;

  const MapPage({
    super.key,
    required this.locationName,
    required this.allSpaces,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locationName),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(10.5276, 76.2144), // Thrissur
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.spacebook',
          ),

          /// 🔥 Dynamic markers from backend
          MarkerLayer(
            markers: allSpaces.map((space) {
              final lat = double.tryParse(space['latitude'].toString()) ?? 10.5276;
              final lng = double.tryParse(space['longitude'].toString()) ?? 76.2144;

              return Marker(
                point: LatLng(lat, lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                        padding: const EdgeInsets.all(16),
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              space['title'] ?? 'Space',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("₹${space['price_per_hr'] ?? 0}/hr"),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}