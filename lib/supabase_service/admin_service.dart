import 'package:supabase_flutter/supabase_flutter.dart';


class AdminService {
   final SupabaseClient _supabase = Supabase.instance.client;

   Future<List<Map<String, dynamic>>?> getAllUsers() async {
    final response = await _supabase
        .from('profiles')
        .select();
        
    return List<Map<String, dynamic>>.from(response);// Mengambil semua kolom

  }

   Future<void> updateUserProfile({
    required String userId,
    required String name,
    required int age,
    required int tinggiBadan,
    required int beratBadan,
    required String? gender,
    required String? status,
  }) async {
    // ignore: unused_local_variable
    final response = await _supabase.from('profiles').update({
      'name': name,
      'age': age,
      'height': tinggiBadan,
      'weight': beratBadan,
      'gender': gender,
      'status' : status,
    }).eq('id', userId);
  }

   Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

   Future<List<Map<String, dynamic>>> getMedicalRecordsByRecordId(
      String userId) async {
    final response = await _supabase
        .from('medical_records') // Assuming you have a 'medical_records' table
        .select()
        .eq('profile_id', userId)  // Using 'user_id' to filter by the user's records
        .order('created_at', ascending: false); // Optionally order by date or any other field

    return List<Map<String, dynamic>>.from(response);
  }


}