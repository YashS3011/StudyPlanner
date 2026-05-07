import 'package:flutter/material.dart';
import '../models/subject.dart';
import 'progress_bar.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final double completion;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.completion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomProgressBar(
            value: completion,
            label: subject.name,
          ),
        ),
      ),
    );
  }
}
