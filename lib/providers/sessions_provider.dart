import 'package:flutter/material.dart';
import '../models/session.dart';
import '../supabase_client.dart';

class SessionsProvider with ChangeNotifier {
  List<StudySession> _sessions = [];
  bool _isLoading = false;

  List<StudySession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> fetchSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseConfig.client.from('sessions').select().order('scheduled_at');
      _sessions = (data as List).map((json) => StudySession.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSession({
    required String subjectId,
    required String topicId,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    // Conflict Check
    final newStart = scheduledAt;
    final newEnd = scheduledAt.add(Duration(minutes: durationMinutes));

    for (var session in _sessions) {
      final existingStart = session.scheduledAt;
      final existingEnd = session.scheduledAt.add(Duration(minutes: session.durationMinutes));

      if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
        throw Exception('Schedule Conflict: This time slot overlaps with an existing session.');
      }
    }

    try {
      final response = await SupabaseConfig.client.from('sessions').insert({
        'subject_id': subjectId,
        'topic_id': topicId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
      }).select().single();
      _sessions.add(StudySession.fromJson(response));
      _sessions.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await SupabaseConfig.client.from('sessions').delete().eq('id', id);
      _sessions.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
