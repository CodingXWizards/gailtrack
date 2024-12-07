import 'package:flutter/material.dart';

class RequestAll extends StatefulWidget {
  const RequestAll({super.key});

  @override
  State<RequestAll> createState() => RequestAllState();
}

class RequestAllState extends State<RequestAll> {
  final List<Map<String, dynamic>> requests = [
    {"title": "Surveyors", "dateTime": "Dec 20, 2023, 12:00 PM"},
    {"title": "Work from home", "dateTime": "Dec 21, 2023, 9:00 AM"},
    {"title": "Work from home", "dateTime": "Dec 22, 2023, 9:00 AM"},
    {"title": "Work from home", "dateTime": "Dec 23, 2023, 9:00 AM"},
    {"title": "Work from home", "dateTime": "Dec 24, 2023, 9:00 AM"},
    {"title": "Work from home", "dateTime": "Dec 25, 2023, 9:00 AM"},
  ];

  // Dummy functions to simulate API calls
  void approveRequest(int index) {
    setState(() {
      // For now, just remove the approved request from the list
      requests.removeAt(index);
    });
    // TODO: Replace with API integration
    print("Approved request at index $index");
  }

  void denyRequest(int index) {
    setState(() {
      // For now, just remove the denied request from the list
      requests.removeAt(index);
    });
    // TODO: Replace with API integration
    print("Denied request at index $index");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "All Requests",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: requests.isEmpty
            ? Center(
                child: Text(
                  "No requests available",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request['title'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  request['dateTime'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => approveRequest(index),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF333333)),
                                child: const Text("Approve"),
                              ),
                              const SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () => denyRequest(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 189, 39, 39),
                                ),
                                child: const Text("Deny"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
