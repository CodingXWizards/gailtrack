import 'package:flutter/material.dart';
import 'package:gailtrack/screens/home/components/custom_card.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: BoxContainer(
                  child: Column(
                    children: [
                      Text(
                        "Checked-in",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text("8:45am",
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BoxContainer(
                  child: Column(
                    children: [
                      Text(
                        "Checked-out",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text("------",
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BoxContainer(
            child: Column(
              children: [
                Text(
                  "Working Hours",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text("9 hours 7 minutes",
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomCard(
            title: "Offisite Work",
            description:
                "You can request to work offsite if you're unable to come in.",
            buttonText: "Request Offsite Work",
            imagePath: "assets/images/bg1.png",
            onPressed: () =>
                Navigator.of(context).pushNamed('/request/offsite'),
          ),
          const SizedBox(height: 32),
          CustomCard(
            title: "Request a leave or HalfDay",
            description:
                "You can request a leave from a work to your superiors.",
            buttonText: "Request a leave",
            imagePath: "assets/images/bg1.png",
            onPressed: () => Navigator.pushNamed(context, '/request/leave'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.white)),
              onPressed: () {},
              child: Text(
                "Leaderboard",
                style: Theme.of(context).textTheme.labelSmall,
              ))
        ],
      ),
    );
  }
}
