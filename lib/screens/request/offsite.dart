import 'package:flutter/material.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RequestOffsite extends StatefulWidget {
  const RequestOffsite({super.key});

  @override
  State<RequestOffsite> createState() => _RequestOffsiteState();
}

class _RequestOffsiteState extends State<RequestOffsite> {
  late MapboxMap _mapboxMap;
  String selectedLocation = 'Mumbai, Office';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Offsite Request",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employee name',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Asmi xyzwk',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Email',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'asmi.xyzxaa@company.com',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Phone',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '+1 (415) 12 3-4567',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Select the location',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                activeColor: Theme.of(context).focusColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                dense: true,
                contentPadding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                title: const Text('Delhi, HQ'),
                value: 'Delhi, HQ',
                groupValue: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value!;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: Theme.of(context).focusColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                dense: true,
                contentPadding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                title: const Text('Mumbai, Office'),
                value: 'Mumbai, Office',
                groupValue: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                height: 250,
                child: MapWidget(
                  key: const ValueKey("mapWidget"),
                  cameraOptions: CameraOptions(
                      center: Point(coordinates: Position(-98.0, 39.5)),
                      zoom: 7,
                      bearing: 0,
                      pitch: 0),
                  onMapCreated: (mapboxMap) {
                    _mapboxMap = mapboxMap;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                        text: "Cancel",
                        bgColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).focusColor,
                        onTap: () {}),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyButton(
                        text: "Confirm",
                        bgColor: Theme.of(context).focusColor,
                        textColor: Theme.of(context).primaryColor,
                        onTap: () {}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
