import 'package:flutter/material.dart';
import 'label.dart';

class TopLabelBar extends StatelessWidget {
  const TopLabelBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Label(text: '직원 A'),
          SizedBox(width: 4),
          Label(text: '차량 B'),
        ],
      ),
    );
  }
}
