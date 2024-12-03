import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RequestLeave extends StatefulWidget {
  const RequestLeave({super.key});

  @override
  State<RequestLeave> createState() => _RequestLeaveState();
}

class _RequestLeaveState extends State<RequestLeave> {
  late MapboxMap _mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Offsite Leave",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: CameraOptions(
            center: Point(coordinates: Position(-98.0, 39.5)),
            zoom: 2,
            bearing: 0,
            pitch: 0),
        onMapCreated: (mapboxMap) {
          _mapboxMap = mapboxMap;
        },
      ),
    );
  }
}
