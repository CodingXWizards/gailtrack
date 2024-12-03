import 'package:flutter/material.dart';

class RequestOffsite extends StatefulWidget {
  const RequestOffsite({super.key});

  @override
  State<RequestOffsite> createState() => _RequestOffsiteState();
}

class _RequestOffsiteState extends State<RequestOffsite> {
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
      body: Padding(
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
              'Select the location',
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
            Center(
              child: SizedBox(
                width: 200, // Adjust width as needed
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.normal),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Set New Location'),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for Cancel
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          color: Colors.white,
                        )),
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
                        textStyle: const TextStyle(
                          color: Colors.black,
                        )),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
