import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';
import '../models/topic.dart';
import '../widgets/progress_bar.dart';
import 'search_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectsProvider>();
    final subjects = provider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final subjectTopics = provider.topics.where((t) => t.subjectId == subject.id).toList();
                final completion = provider.getSubjectCompletion(subject.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CustomProgressBar(value: completion, label: subject.name),
                      ),
                      if (subjectTopics.isNotEmpty) ...[
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: subjectTopics.map((topic) => _buildTopicRow(context, provider, topic)).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTopicRow(BuildContext context, SubjectsProvider provider, Topic topic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(topic.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${topic.progress}% Completed',
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey[300]),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showProgressUpdateDialog(context, provider, topic),
            borderRadius: BorderRadius.circular(20),
            child: _StatusChip(status: topic.status),
          ),
        ],
      ),
    );
  }

  void _showProgressUpdateDialog(BuildContext context, SubjectsProvider provider, Topic topic) {
    int currentProgress = topic.progress;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update "${topic.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Progress: $currentProgress%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Slider(
                value: currentProgress.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '$currentProgress%',
                onChanged: (val) => setDialogState(() => currentProgress = val.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                provider.updateTopicProgress(topic.id, currentProgress);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _cycleStatus(SubjectsProvider provider, Topic topic) {
    TopicStatus nextStatus;
    switch (topic.status) {
      case TopicStatus.notStarted:
        nextStatus = TopicStatus.inProgress;
        break;
      case TopicStatus.inProgress:
        nextStatus = TopicStatus.completed;
        break;
      case TopicStatus.completed:
        nextStatus = TopicStatus.notStarted;
        break;
    }
    provider.updateTopicStatus(topic.id, nextStatus);
  }

  Color _getStatusColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted: return const Color(0xFF94A3B8);
      case TopicStatus.inProgress: return const Color(0xFFF59E0B);
      case TopicStatus.completed: return const Color(0xFF10B981);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final TopicStatus status;

  const _StatusChip({required this.status});

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
