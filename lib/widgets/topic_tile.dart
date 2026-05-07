import 'package:flutter/material.dart';
import '../models/topic.dart';

class TopicTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TopicTile({
    super.key,
    required this.topic,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        topic.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        '${topic.progress}% Completed • ${topic.estimatedMinutes} mins',
        style: TextStyle(color: Colors.blueGrey[400], fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusBadge(status: topic.status),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TopicStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TopicStatus.notStarted: color = const Color(0xFF94A3B8); break;
      case TopicStatus.inProgress: color = const Color(0xFFF59E0B); break;
      case TopicStatus.completed: color = const Color(0xFF10B981); break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}
