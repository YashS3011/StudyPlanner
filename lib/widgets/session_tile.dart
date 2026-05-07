import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../models/topic.dart';

class SessionTile extends StatelessWidget {
  final StudySession session;
  final Topic topic;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusTap;

  const SessionTile({
    super.key,
    required this.session,
    required this.topic,
    this.onDelete,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(Icons.event, color: Theme.of(context).primaryColor),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(topic.name)),
          InkWell(
            onTap: onStatusTap,
            child: _StatusBadge(status: topic.status),
          ),
        ],
      ),
      subtitle: Text(
        '${DateFormat('MMM dd, yyyy').format(session.scheduledAt)} at ${DateFormat('hh:mm a').format(session.scheduledAt)}\nDuration: ${session.durationMinutes} mins',
      ),
      isThreeLine: true,
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            )
          : null,
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
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
