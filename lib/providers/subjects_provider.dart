import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../supabase_client.dart';

class SubjectsProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  List<Topic> _topics = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final subjectData = await SupabaseConfig.client.from('subjects').select().order('created_at');
      _subjects = (subjectData as List).map((json) => Subject.fromJson(json)).toList();

      final topicData = await SupabaseConfig.client.from('topics').select().order('created_at');
      _topics = (topicData as List).map((json) => Topic.fromJson(json)).toList();

      await _saveToCache();
    } catch (e) {
      debugPrint('Error fetching subjects/topics: $e');
      await _loadFromCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    // Simplified caching for dev purposes
    // In a real app, we'd serialize the objects properly
  }

  Future<void> _loadFromCache() async {
    // Basic offline support: read from memory if fetch fails
  }

  Future<void> addSubject(String name) async {
    try {
      final response = await SupabaseConfig.client.from('subjects').insert({'name': name}).select().single();
      _subjects.add(Subject.fromJson(response));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await SupabaseConfig.client.from('subjects').delete().eq('id', id);
      _subjects.removeWhere((s) => s.id == id);
      _topics.removeWhere((t) => t.subjectId == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTopic(String subjectId, String name, int estimatedMinutes) async {
    try {
      final response = await SupabaseConfig.client.from('topics').insert({
        'subject_id': subjectId,
        'name': name,
        'estimated_minutes': estimatedMinutes,
      }).select().single();
      _topics.add(Topic.fromJson(response));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTopic(String id) async {
    try {
      await SupabaseConfig.client.from('topics').delete().eq('id', id);
      _topics.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTopicStatus(String id, TopicStatus status) async {
    try {
      await SupabaseConfig.client.from('topics').update({'status': status.value}).eq('id', id);
      final index = _topics.indexWhere((t) => t.id == id);
      if (index != -1) {
        _topics[index] = _topics[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  double getSubjectCompletion(String subjectId) {
    final subjectTopics = _topics.where((t) => t.subjectId == subjectId).toList();
    if (subjectTopics.isEmpty) return 0.0;
    final completedCount = subjectTopics.where((t) => t.status == TopicStatus.completed).length;
    return completedCount / subjectTopics.length;
  }
}
