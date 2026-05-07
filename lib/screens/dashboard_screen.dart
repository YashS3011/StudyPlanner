import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';
import '../models/topic.dart';
import '../widgets/subject_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectsProvider = context.watch<SubjectsProvider>();
    final subjects = subjectsProvider.subjects;
    final topics = subjectsProvider.topics;

    final completedTopics = topics.where((t) => t.status == TopicStatus.completed).length;
    final pendingTopics = topics.length - completedTopics;

    // Find subject with lowest completion
    String? lowestSubjectId;
    double lowestCompletion = 1.1;
    for (var s in subjects) {
      double comp = subjectsProvider.getSubjectCompletion(s.id);
      if (comp < lowestCompletion) {
        lowestCompletion = comp;
        lowestSubjectId = s.id;
      }
    }

    final suggestedTopic = lowestSubjectId != null 
      ? topics.firstWhere((t) => t.subjectId == lowestSubjectId && t.status == TopicStatus.notStarted, orElse: () => topics.firstWhere((t) => t.status == TopicStatus.notStarted, orElse: () => Topic(id: '', subjectId: '', name: 'No topics suggested', estimatedMinutes: 0, status: TopicStatus.notStarted, createdAt: DateTime.now())))
      : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: subjectsProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsCard(context, subjects.length, completedTopics, pendingTopics),
              const SizedBox(height: 24),
              if (suggestedTopic != null && suggestedTopic.id.isNotEmpty)
                _buildSuggestedTopicCard(context, suggestedTopic),
              const SizedBox(height: 24),
              Text('Subject Progress', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...subjects.map((s) => SubjectCard(
                subject: s,
                completion: subjectsProvider.getSubjectCompletion(s.id),
              )),
            ],
          ),
    );
  }

  Widget _buildStatsCard(BuildContext context, int totalSubjects, int completed, int pending) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Subjects', totalSubjects.toString()),
            _buildStatItem(context, 'Completed', completed.toString()),
            _buildStatItem(context, 'Pending', pending.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).primaryColor)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSuggestedTopicCard(BuildContext context, Topic topic) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        title: const Text('Suggested Next Topic'),
        subtitle: Text(topic.name),
        trailing: const Icon(Icons.lightbulb_outline),
      ),
    );
  }
}
