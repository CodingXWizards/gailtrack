import 'package:flutter/material.dart';

class OffsiteRequestPage extends StatefulWidget {
  const OffsiteRequestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OffsiteRequestBodyState createState() => _OffsiteRequestBodyState();
}

class _OffsiteRequestBodyState extends State<OffsiteRequestPage> {
  String selectedLocation = 'Mumbai, Office';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee name',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Text(
            'Asmi xyzwk',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Text(
            'asmi.xyzxaa@company.com',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Phone',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            '+1 (415) 12 3-4567',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 32),
          const Text(
            'Select the location of the employee',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
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
            title: const Text('Mumbai, Office'),
            value: 'Mumbai, Office',
            groupValue: selectedLocation,
            onChanged: (value) {
              setState(() {
                selectedLocation = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Set New Location'),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // for Cancel
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Action for Confirm
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
