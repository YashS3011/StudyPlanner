import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/subjects_provider.dart';
import '../providers/sessions_provider.dart';
import '../models/topic.dart';
import '../widgets/session_tile.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _selectedSubjectId;
  String? _selectedTopicId;
  DateTime? _selectedDateTime;
  final _durationController = TextEditingController(text: '60');

  @override
  Widget build(BuildContext context) {
    final subjectsProvider = context.watch<SubjectsProvider>();
    final sessionsProvider = context.watch<SessionsProvider>();

    final List<Topic> filteredTopics = _selectedSubjectId != null
        ? subjectsProvider.topics.where((t) => t.subjectId == _selectedSubjectId).toList()
        : <Topic>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Study Schedule')),
      body: Column(
        children: [
          _buildSessionForm(subjectsProvider, filteredTopics),
          const Divider(),
          Expanded(
            child: sessionsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: sessionsProvider.sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessionsProvider.sessions[index];
                      final topic = subjectsProvider.topics.firstWhere(
                        (t) => t.id == session.topicId,
                        orElse: () => Topic(id: '', subjectId: '', name: 'Unknown Topic', estimatedMinutes: 0, status: TopicStatus.notStarted, createdAt: DateTime.now()),
                      );

                      return SessionTile(
                        session: session,
                        topic: topic,
                        onDelete: () => sessionsProvider.deleteSession(session.id),
                        onStatusTap: () => _cycleTopicStatus(subjectsProvider, topic),
                      );
                    },
                  ),
          ),
        ],
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

  Widget _buildSessionForm(SubjectsProvider provider, List<Topic> topics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedSubjectId,
            hint: const Text('Select Subject'),
            items: provider.subjects.map((s) => DropdownMenuItem<String>(value: s.id, child: Text(s.name))).toList(),
            onChanged: (val) => setState(() {
              _selectedSubjectId = val;
              _selectedTopicId = null;
            }),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTopicId,
            hint: const Text('Select Topic'),
            items: topics.map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.name))).toList(),
            onChanged: (val) => setState(() => _selectedTopicId = val),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDateTime(context),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_selectedDateTime == null ? 'Pick Date & Time' : DateFormat('MMM dd, hh:mm a').format(_selectedDateTime!)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Mins', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
            child: const Text('Schedule Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _submitForm() {
    if (_selectedSubjectId == null || _selectedTopicId == null || _selectedDateTime == null || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    context.read<SessionsProvider>().addSession(
          subjectId: _selectedSubjectId!,
          topicId: _selectedTopicId!,
          scheduledAt: _selectedDateTime!,
          durationMinutes: int.parse(_durationController.text),
        );

    setState(() {
      _selectedSubjectId = null;
      _selectedTopicId = null;
      _selectedDateTime = null;
    });
  }
}
