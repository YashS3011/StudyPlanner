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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomProgressBar(
              value: completion,
              label: subject.name,
            ),
          ),
        ),
      ),
    );
  }
}
