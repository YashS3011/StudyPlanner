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
      title: Text(topic.name),
      subtitle: Text('${topic.estimatedMinutes} mins • ${topic.status.displayName}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusBadge(status: topic.status),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
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
      case TopicStatus.notStarted: color = Colors.grey; break;
      case TopicStatus.inProgress: color = Colors.orange; break;
      case TopicStatus.completed: color = Colors.green; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
