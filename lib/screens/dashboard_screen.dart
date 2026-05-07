import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';
import '../providers/sessions_provider.dart';
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
      ? topics.firstWhere((t) => t.subjectId == lowestSubjectId && t.status == TopicStatus.notStarted, orElse: () => topics.firstWhere((t) => t.status == TopicStatus.notStarted, orElse: () => Topic(id: '', subjectId: '', name: 'No topics suggested', estimatedMinutes: 0, status: TopicStatus.notStarted, progress: 0, createdAt: DateTime.now())))
      : null;

    final now = DateTime.now();
    final todaySessions = context.watch<SessionsProvider>().sessions.where((s) => 
      s.scheduledAt.year == now.year && s.scheduledAt.month == now.month && s.scheduledAt.day == now.day).toList();
    final todayMinutes = todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return Scaffold(
      body: subjectsProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Smart Planner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).primaryColor, const Color(0xFF818CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text('Welcome back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const Text('Here is your study progress overview.', style: TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 24),
                    _buildStatsCard(context, subjects.length, completedTopics, pendingTopics),
                    const SizedBox(height: 24),
                    _buildDailyProgressCard(context, todayMinutes, todaySessions.length),
                    const SizedBox(height: 32),
                    if (suggestedTopic != null && suggestedTopic.id.isNotEmpty) ...[
                      const Text('Recommended For You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 12),
                      _buildSuggestedTopicCard(context, suggestedTopic),
                      const SizedBox(height: 32),
                    ],
                    const Text('Subject Mastery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 12),
                    ...subjects.map((s) => SubjectCard(
                      subject: s,
                      completion: subjectsProvider.getSubjectCompletion(s.id),
                    )),
                  ]),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDailyProgressCard(BuildContext context, int minutes, int sessionCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: minutes > 0 ? 1.0 : 0.0, // Placeholder for actual daily completion
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(Icons.today_rounded, color: Theme.of(context).primaryColor),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  sessionCount == 0 ? "No sessions today" : "$sessionCount sessions • $minutes total mins",
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, int totalSubjects, int completed, int pending) {
    return Row(
      children: [
        Expanded(child: _buildStatItem(context, 'Subjects', totalSubjects.toString(), Icons.book_rounded, Colors.indigo)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(context, 'Done', completed.toString(), Icons.check_circle_rounded, const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(context, 'Pending', pending.toString(), Icons.timer_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildSuggestedTopicCard(BuildContext context, Topic topic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.secondary, const Color(0xFFF472B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('UP NEXT', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(topic.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
