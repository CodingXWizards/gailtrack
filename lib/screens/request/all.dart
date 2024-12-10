import 'package:flutter/material.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:gailtrack/state/request/model.dart';
import 'package:gailtrack/state/request/provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    List<Request> requestList =
        Provider.of<RequestProvider>(context).requestList;

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
        child: requestList.isEmpty
            ? Center(
                child: Text(
                  "No requests found",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : ListView.builder(
                itemCount: requestList.length,
                itemBuilder: (context, index) {
                  final request = requestList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.label,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "From: ${DateFormat("dd MMM yyyy").format(request.startDate)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              "To: ${DateFormat("dd MMM yyyy").format(request.startDate)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            MyButton(
                              text: "Accept",
                              type: ButtonType.secondary,
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            MyButton(
                              text: "Deny",
                              onTap: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
