import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final String imagePath;
  final VoidCallback onPressed;

  const CustomCard(
      {super.key,
      required this.title,
      required this.description,
      required this.buttonText,
      required this.imagePath,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(description,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Image(image: AssetImage(imagePath)))
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          width: double.infinity,
          child: ElevatedButton(
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: Theme.of(context).textTheme.labelLarge,
              )),
        )
      ],
    );
  }
}
