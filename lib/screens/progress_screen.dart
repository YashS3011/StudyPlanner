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
        title: const Text('Progress Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomProgressBar(value: completion, label: subject.name),
                        const SizedBox(height: 12),
                        const Divider(),
                        ...subjectTopics.map((topic) => _buildTopicRow(context, provider, topic)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTopicRow(BuildContext context, SubjectsProvider provider, Topic topic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(topic.name)),
          InkWell(
            onTap: () => _cycleStatus(provider, topic),
            child: Chip(
              label: Text(topic.status.displayName, style: const TextStyle(fontSize: 10)),
              backgroundColor: _getStatusColor(topic.status).withOpacity(0.2),
              side: BorderSide(color: _getStatusColor(topic.status)),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
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
      case TopicStatus.notStarted:
        return Colors.grey;
      case TopicStatus.inProgress:
        return Colors.orange;
      case TopicStatus.completed:
        return Colors.green;
    }
  }
}
