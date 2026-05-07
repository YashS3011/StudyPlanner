import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';
import '../models/topic.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  TopicStatus? _statusFilter;
  String? _subjectFilter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectsProvider>();
    
    final filteredTopics = provider.topics.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || t.status == _statusFilter;
      final matchesSubject = _subjectFilter == null || t.subjectId == _subjectFilter;
      return matchesSearch && matchesStatus && matchesSubject;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          _buildFilters(provider),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                final subject = provider.subjects.firstWhere((s) => s.id == topic.subjectId, orElse: () => provider.subjects.first);
                return ListTile(
                  title: Text(topic.name),
                  subtitle: Text(subject.name),
                  trailing: Chip(
                    label: Text(topic.status.displayName, style: const TextStyle(fontSize: 10)),
                    backgroundColor: _getStatusColor(topic.status).withOpacity(0.1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(SubjectsProvider provider) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _statusFilter == null,
                onSelected: (_) => setState(() => _statusFilter = null),
              ),
              const SizedBox(width: 8),
              ...TopicStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status.displayName),
                  selected: _statusFilter == status,
                  onSelected: (_) => setState(() => _statusFilter = status),
                ),
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Filter by Subject'),
            value: _subjectFilter,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Subjects')),
              ...provider.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
            ],
            onChanged: (val) => setState(() => _subjectFilter = val),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted: return Colors.grey;
      case TopicStatus.inProgress: return Colors.orange;
      case TopicStatus.completed: return Colors.green;
    }
  }
}
