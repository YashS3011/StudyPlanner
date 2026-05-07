import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';
import '../models/topic.dart';
import 'search_screen.dart';
import '../widgets/topic_tile.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectsProvider>();
    final subjects = provider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects & Topics'),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final subjectTopics = provider.topics.where((t) => t.subjectId == subject.id).toList();

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(subject.name[0].toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${subjectTopics.length} topics', style: const TextStyle(fontSize: 12)),
                      children: [
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ...subjectTopics.map((topic) => TopicTile(
                              topic: topic,
                              onDelete: () => provider.deleteTopic(topic.id),
                              onTap: () => _cycleTopicStatus(provider, topic),
                            )),
                        ListTile(
                          leading: const Icon(Icons.add_circle_outline, color: Color(0xFF64748B)),
                          title: const Text('Add New Topic', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                          onTap: () => _showAddTopicDialog(context, subject.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context),
        label: const Text('New Subject'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _cycleTopicStatus(SubjectsProvider provider, Topic topic) {
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

  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Subject'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Subject Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<SubjectsProvider>().addSubject(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, String subjectId) {
    final nameController = TextEditingController();
    final minsController = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Topic Name')),
            TextField(
              controller: minsController,
              decoration: const InputDecoration(hintText: 'Est. Minutes'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<SubjectsProvider>().addTopic(
                      subjectId,
                      nameController.text,
                      int.tryParse(minsController.text) ?? 30,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
