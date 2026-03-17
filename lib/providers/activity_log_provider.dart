import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityLogProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<List<ActivityLog>> getLogs({int limit = 50, int offset = 0}) async {
    final query = await supabase
        .from('activity_logs')
        .select('*, activity_actions(*), profiles(*)')
        .order('timestamp', ascending: false)
        .range(offset, offset + limit - 1);
    final result = List.generate(
      query.length,
      (i) => ActivityLog.fromJson(query[i]),
    );
    return result;
  }

  Future<void> addLog({
    required int actionId,
    required String description,
    required String performedBy,
    required int performedById,
    Map<String, dynamic>? metadata,
  }) async {
    await supabase.from('activity_logs').insert({
      'action_id': actionId,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
      'performed_by': performedBy,
      'performed_by_id': performedById,
      'metadata': metadata,
    });
    notifyListeners();
  }
}
