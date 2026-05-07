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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.calendar_today_rounded, color: Theme.of(context).primaryColor, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                topic.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            InkWell(
              onTap: onStatusTap,
              child: _StatusBadge(status: topic.status),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.blueGrey[300]),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(session.scheduledAt)} • ${DateFormat('hh:mm a').format(session.scheduledAt)}',
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.blueGrey[300]),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${session.durationMinutes} mins',
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                onPressed: onDelete,
              )
            : null,
      ),
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
