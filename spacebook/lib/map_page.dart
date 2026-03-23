import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const Color _green = Color(0xFF3F6B00);

class MapPage extends StatefulWidget {
  final String locationName;
  final List<Map<String, dynamic>>? allSpaces; // optional: show all spaces

  const MapPage({
    super.key,
    required this.locationName,
    this.allSpaces,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  InAppWebViewController? _webController;
  bool _isLoading = true;

  String _buildMarkersJs() {
    if (widget.allSpaces == null || widget.allSpaces!.isEmpty) return '';

    final buffer = StringBuffer();
    for (final space in widget.allSpaces!) {
      final title = (space['title'] ?? '').toString().replaceAll("'", "\\'");
      final area = (space['area'] ?? '').toString().replaceAll("'", "\\'");
      final price = space['price_per_hr']?.toString() ?? '0';
      buffer.writeln('''
        geocodeAndMark('$area', '$title', '₹$price/hr');
      ''');
    }
    return buffer.toString();
  }

  String _buildHtml() {
    final isAllSpaces = widget.allSpaces != null && widget.allSpaces!.isNotEmpty;
    final searchQuery = Uri.encodeComponent(widget.locationName);
    final markersJs = _buildMarkersJs();

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SpaceBook Map</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, sans-serif; background: #f0f4f0; }
    #map { height: 100vh; width: 100vw; }
    .loading-overlay {
      position: fixed; top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(255,255,255,0.9);
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      z-index: 9999; transition: opacity 0.3s;
    }
    .loading-overlay.hidden { opacity: 0; pointer-events: none; }
    .spinner {
      width: 44px; height: 44px;
      border: 4px solid #e0e0e0;
      border-top-color: #3F6B00;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
      margin-bottom: 14px;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .loading-text { color: #3F6B00; font-size: 15px; font-weight: 600; }
    .leaflet-popup-content-wrapper {
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    }
    .popup-title { font-weight: 700; font-size: 14px; color: #1a1a1a; margin-bottom: 4px; }
    .popup-area { font-size: 12px; color: #666; margin-bottom: 6px; }
    .popup-price { 
      font-size: 13px; font-weight: 700; color: #3F6B00;
      background: #E8F5E9; padding: 4px 8px; border-radius: 6px;
      display: inline-block;
    }
    .custom-marker {
      background: #3F6B00;
      border: 3px solid white;
      border-radius: 50% 50% 50% 0;
      transform: rotate(-45deg);
      box-shadow: 0 3px 10px rgba(0,0,0,0.3);
    }
    .custom-marker-inner {
      width: 100%; height: 100%;
      display: flex; align-items: center; justify-content: center;
      transform: rotate(45deg);
      color: white; font-size: 14px;
    }
  </style>
</head>
<body>
  <div class="loading-overlay" id="loadingOverlay">
    <div class="spinner"></div>
    <div class="loading-text">Finding location...</div>
  </div>
  <div id="map"></div>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script>
    const map = L.map('map', { zoomControl: true });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 19,
    }).addTo(map);

    function hideLoader() {
      document.getElementById('loadingOverlay').classList.add('hidden');
    }

    function createIcon(emoji) {
      return L.divIcon({
        html: '<div class="custom-marker" style="width:32px;height:32px"><div class="custom-marker-inner">' + emoji + '</div></div>',
        className: '',
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -34],
      });
    }

    function geocodeAndMark(address, title, price) {
      const encoded = encodeURIComponent(address);
      fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encoded + '&limit=1', {
        headers: { 'Accept-Language': 'en' }
      })
      .then(r => r.json())
      .then(data => {
        if (data && data.length > 0) {
          const lat = parseFloat(data[0].lat);
          const lon = parseFloat(data[0].lon);
          const marker = L.marker([lat, lon], { icon: createIcon('🏢') }).addTo(map);
          marker.bindPopup(
            '<div class="popup-title">' + title + '</div>' +
            '<div class="popup-area">📍 ' + address + '</div>' +
            '<div class="popup-price">' + price + '</div>'
          );
        }
      })
      .catch(e => console.log('Geocode error:', e));
    }

    ${isAllSpaces ? '''
      // Show all spaces mode
      map.setView([20.5937, 78.9629], 5); // India center
      $markersJs
      setTimeout(hideLoader, 2000);
    ''' : '''
      // Single location mode
      fetch('https://nominatim.openstreetmap.org/search?format=json&q=$searchQuery&limit=1', {
        headers: { 'Accept-Language': 'en' }
      })
      .then(r => r.json())
      .then(data => {
        hideLoader();
        if (data && data.length > 0) {
          const lat = parseFloat(data[0].lat);
          const lon = parseFloat(data[0].lon);
          map.setView([lat, lon], 15);
          const marker = L.marker([lat, lon], { icon: createIcon('📍') }).addTo(map);
          marker.bindPopup(
            '<div class="popup-title">${widget.locationName.replaceAll("'", "\\'")}</div>' +
            '<div class="popup-area">📍 ${widget.locationName.replaceAll("'", "\\'")}</div>'
          ).openPopup();
        } else {
          map.setView([20.5937, 78.9629], 5);
          alert('Location not found. Please try a more specific address.');
        }
      })
      .catch(() => {
        hideLoader();
        map.setView([20.5937, 78.9629], 5);
      });
    '''}
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.allSpaces != null
        ? 'All Spaces Map'
        : widget.locationName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.length > 30 ? '${title.substring(0, 30)}...' : title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'OpenStreetMap',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: _green),
            onPressed: () {
              _webController?.reload();
            },
            tooltip: 'Reload map',
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _buildHtml(),
              mimeType: 'text/html',
              encoding: 'utf-8',
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controller) {
              _webController = controller;
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _green),
                    SizedBox(height: 16),
                    Text('Loading map...',
                        style: TextStyle(color: _green, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}