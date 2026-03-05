import 'package:supabase_flutter/supabase_flutter.dart';
import '../Dashboard/task_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  Future<List<Task>> fetchTasks() async {
    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => Task.fromJson(row)).toList();
  }

  Future<Task> addTask(String title) async {
    final response = await _supabase
        .from('tasks')
        .insert({'title': title, 'completed': false, 'user_id': _userId})
        .select()
        .single();

    return Task.fromJson(response);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  Future<void> toggleTask(String taskId, bool completed) async {
    await _supabase
        .from('tasks')
        .update({'completed': completed})
        .eq('id', taskId);
  }

  Future<void> editTask(String taskId, String newTitle) async {
    await _supabase.from('tasks').update({'title': newTitle}).eq('id', taskId);
  }
}
