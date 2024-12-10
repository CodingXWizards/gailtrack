import 'package:flutter/material.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';
import 'package:gailtrack/screens/request/detailpage.dart';
import 'package:gailtrack/screens/request/statcard.dart';

class RequestMembers extends StatefulWidget {
  const RequestMembers({super.key});

  @override
  State<RequestMembers> createState() => RequestMembersState();
}

class RequestMembersState extends State<RequestMembers> {
  // Dummy API URLs (replace with your actual endpoints)
  // final String statsApiUrl = 'https://example.com/api/stats';
  // final String employeesApiUrl = 'https://example.com/api/employees';

  // late Future<Map<String, dynamic>> statsData;
  late Future<List<Map<String, dynamic>>> employeesData;

  // @override
  // void initState() {
  //   super.initState();
  //   statsData = fetchStats();
  //   employeesData = fetchEmployees();
  // }

  // // Fetch stats data
  // Future<Map<String, dynamic>> fetchStats() async {
  //   final response = await http.get(Uri.parse(statsApiUrl));
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body); // Example response: {"total": 452, "absent": 30}
  //   } else {
  //     throw Exception('Failed to load stats');
  //   }
  // }

  // // Fetch employees data
  // Future<List<Map<String, dynamic>>> fetchEmployees() async {
  //   final response = await http.get(Uri.parse(employeesApiUrl));
  //   if (response.statusCode == 200) {
  //     return List<Map<String, dynamic>>.from(json.decode(response.body));
  //     // Example response: [{"name": "Mayank", "status": "present", "time": "09:30 am"}, ...]
  //   } else {
  //     throw Exception('Failed to load employees');
  //   }
  // }

  //badme api jodna
  final List<Map<String, dynamic>> employees = [
    {
      'name': 'Mayank',
      'status': 'present',
      'time': '09:30 am',
      'workType': 'Offsite',
      'checkIn': '09:30 am',
      'checkOut': '--'
    },
    {
      'name': 'Pratham',
      'status': 'present',
      'time': '10:40 am',
      'workType': 'Offsite',
      'checkIn': '10:40 am',
      'checkOut': '--'
    },
    {
      'name': 'Bhavesh',
      'status': 'absent',
      'time': null,
      'workType': 'N/A',
      'checkIn': '--',
      'checkOut': '--'
    },
    {
      'name': 'Gargi',
      'status': 'present',
      'time': '12:10 pm',
      'workType': 'Onsite',
      'checkIn': '12:10 pm',
      'checkOut': '--'
    },
    {
      'name': 'Champak',
      'status': 'absent',
      'time': null,
      'workType': 'N/A',
      'checkIn': '--',
      'checkOut': '--'
    },
    {
      'name': 'Harsh',
      'status': 'present',
      'time': '01:00 pm',
      'workType': 'Onsite',
      'checkIn': '01:00 pm',
      'checkOut': '--'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Manage Members",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Stats Row
            const Row(
              children: [
                Expanded(
                    child: StatCard(title: 'Total Employees', value: '452')),
                SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Absent', value: '30')),
              ],
            ),
            const SizedBox(height: 16),

            // Employee List
            Expanded(
              child: ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return BoxContainer(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Icons.image,
                        color: Colors.grey.shade700,
                        size: 40,
                      ),
                      title: Text(employee['name']),
                      subtitle: Text(
                        employee['status'],
                        style: TextStyle(
                          fontSize: 14,
                          color: employee['status'] == 'absent'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      trailing: Text(employee['time'] ?? '--'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeDetailsScreen(
                              name: employee['name'],
                              workType: employee['workType'],
                              checkIn: employee['checkIn'],
                              checkOut: employee['checkOut'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
