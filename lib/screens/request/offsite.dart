import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RequestOffsite extends StatefulWidget {
  const RequestOffsite({super.key});

  @override
  State<RequestOffsite> createState() => _RequestOffsiteState();
}

class _RequestOffsiteState extends State<RequestOffsite>
    with WidgetsBindingObserver {
  LatLng? selectedLatLng;
  LatLng initialLocation = LatLng(20.5937, 78.9629); // Centered on India
  final TextEditingController searchController = TextEditingController();
  List<dynamic> suggestions = [];
  Timer? _debounce;
  bool isLoading = false;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Fetch location suggestions restricted to India
  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    setState(() => isLoading = true);

    final url =
        "https://nominatim.openstreetmap.org/search?q=$query,India&format=json&addressdetails=1&limit=5";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        setState(() {
          suggestions = results;
        });
      } else {
        setState(() => suggestions = []);
      }
    } catch (_) {
      setState(() => suggestions = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Update map and clear suggestions
  void selectSuggestion(dynamic suggestion) {
    final lat = double.parse(suggestion['lat']);
    final lon = double.parse(suggestion['lon']);
    setState(() {
      initialLocation = LatLng(lat, lon);
      selectedLatLng = initialLocation;
      suggestions = [];
      searchController.text = suggestion['display_name'];
    });
    mapController.move(initialLocation, 14.0);
  }

  // Send POST request with location data
  Future<void> submitLocation() async {
    if (selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location first.')),
      );
      return;
    }

    final url = Uri.parse(
        'https://7bd2-117-96-42-140.ngrok-free.app/offsitelog'); // Replace with actual API URL
    final body = jsonEncode({
      "latitude": selectedLatLng!.latitude,
      "longitude": selectedLatLng!.longitude,
      "location": searchController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location submitted successfully!')),
        );
        Navigator.of(context).pop(); // Navigate back to home page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Send the request to the admin ${response.body}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Optimize TileLayer
  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter:
            initialLocation, // Use `center` instead of `initialCenter`
        initialZoom: 5.0,
        minZoom: 4.0, // Prevent unnecessary far-out tiles
        maxZoom: 16.0, // Limit max zoom level
        onTap: (tapPosition, latLng) {
          setState(() {
            selectedLatLng = latLng;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          tileSize: 256,
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            if (selectedLatLng != null)
              Marker(
                point: selectedLatLng!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search and Pin Location (India)")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (query) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      fetchSuggestions(query);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search for a place in India",
                    prefixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() => suggestions = []);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                if (suggestions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          title: Text(
                            suggestion['display_name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => selectSuggestion(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildMap()),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: submitLocation,
                    child: const Text("Confirm"),
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
