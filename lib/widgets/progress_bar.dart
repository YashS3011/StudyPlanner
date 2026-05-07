import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double value;
  final String label;

  const CustomProgressBar({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFE2E8F0),
            color: Theme.of(context).primaryColor,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
