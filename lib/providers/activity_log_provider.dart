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

  /// Log by action name instead of ID. Looks up the action_id from activity_actions table.
  Future<void> log({
    required String actionName,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final actionRow = await supabase
          .from('activity_actions')
          .select('id')
          .eq('action_name', actionName)
          .maybeSingle();
      if (actionRow == null) {
        debugPrint('[ActivityLog] action "$actionName" not found in activity_actions table');
        return;
      }

      // Get current user profile
      final userId = supabase.auth.currentUser?.id;
      String? performedBy;
      int? performedById;
      if (userId != null) {
        final profile = await supabase
            .from('profiles')
            .select('id, name')
            .eq('user_id', userId)
            .maybeSingle();
        if (profile != null) {
          performedBy = profile['name'] as String;
          performedById = profile['id'] as int;
        }
      }

      debugPrint('[ActivityLog] Inserting log: $actionName — $description (user: $performedBy, id: $performedById)');
      await supabase.from('activity_logs').insert({
        'action_id': actionRow['id'],
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
        'performed_by': performedBy,
        'performed_by_id': performedById,
        'metadata': metadata,
      });
      debugPrint('[ActivityLog] Insert success');
      notifyListeners();
    } catch (e) {
      debugPrint('[ActivityLog] Error logging "$actionName": $e');
    }
  }
}
