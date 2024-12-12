import 'package:flutter/material.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

class People extends StatefulWidget {
  const People({super.key});

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  // Sample leaderboard data
  final List<Map<String, String>> leaderboard = [
    {'name': 'Asmi ', 'rank': '#1'},
    {'name': 'Yash', 'rank': '#2'},
    {'name': 'Raja', 'rank': '#3'},
    {'name': 'Vipin', 'rank': '#4'},
    {'name': 'Jatin', 'rank': '#5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top position with larger BoxContainer
            const BoxContainer(
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asmi Xyz',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '#1',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // List for remaining ranks
            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length -
                    1, // Exclude the top rank already displayed
                itemBuilder: (context, index) {
                  final person = leaderboard[index + 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BoxContainer(
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                        title: Text(
                          person['name']!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          person['rank']!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
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