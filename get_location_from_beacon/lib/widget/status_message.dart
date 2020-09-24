import 'package:flutter/material.dart';

class StatusMessage extends StatelessWidget {
  const StatusMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
}
