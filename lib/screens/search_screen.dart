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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search topics...',
                  hintStyle: TextStyle(color: Colors.blueGrey[200]),
                  prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),
          _buildFilters(provider),
          const SizedBox(height: 12),
          Expanded(
            child: filteredTopics.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      final subject = provider.subjects.firstWhere((s) => s.id == topic.subjectId, orElse: () => provider.subjects.first);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: ListTile(
                          title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(subject.name, style: TextStyle(color: Colors.blueGrey[400], fontSize: 12)),
                          trailing: _StatusChip(status: topic.status),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.blueGrey[100]),
          const SizedBox(height: 16),
          Text('No results found', style: TextStyle(color: Colors.blueGrey[300], fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Try a different search term or filter', style: TextStyle(color: Colors.blueGrey[200], fontSize: 14)),
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
                backgroundColor: Colors.white,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(width: 8),
              ...TopicStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status.displayName),
                  selected: _statusFilter == status,
                  onSelected: (_) => setState(() => _statusFilter = status),
                  backgroundColor: Colors.white,
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
