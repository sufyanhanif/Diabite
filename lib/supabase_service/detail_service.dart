import 'package:supabase_flutter/supabase_flutter.dart';

class DetailService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMedicalRecordsByRecordId(
      String recordId) async {
    final response = await _supabase
        .from('medical_records')
        .select()
        .eq('record_id', recordId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteMedicalRecord(String recordId) async {
    await _supabase.from('medical_records').delete().eq('record_id', recordId);
  }
}
