import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<String?> getCurrentUserName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id;

    final response = await _supabase
        .from('profiles')
        .select('name')
        .eq('id', userId)
        .maybeSingle();

    return response?['name'];
  }

  Future<String?> getCurrentUserGender() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id;

    final response = await _supabase
        .from('profiles')
        .select('gender')
        .eq('id', userId)
        .maybeSingle();

    return response?['gender'];
  }

  Future<int?> getCurrentUserAge() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id;

    final response = await _supabase
        .from('profiles')
        .select('age')
        .eq('id', userId)
        .maybeSingle();

    return response?['age'];
  }

  Future<int?> getCurrentUserTinggiBadan() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id;

    final response = await _supabase
        .from('profiles')
        .select('height')
        .eq('id', userId)
        .maybeSingle();

    return response?['height'];
  }

  Future<int?> getCurrentUserBeratBadan() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id;

    final response = await _supabase
        .from('profiles')
        .select('weight')
        .eq('id', userId)
        .maybeSingle();

    return response?['weight'];
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return;
    }

    // ignore: unused_local_variable
    final response = await _supabase.auth.updateUser(
      UserAttributes(email: newEmail),
    );
    // ignore: unused_local_variable
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required int age,
    required int tinggiBadan,
    required int beratBadan,
    required String? gender,
  }) async {
    // ignore: unused_local_variable
    final response = await _supabase.from('profiles').update({
      'name': name,
      'age': age,
      'height': tinggiBadan,
      'weight': beratBadan,
      'gender': gender,
    }).eq('id', userId);
  }

   Future<String?> getCurrentProfileId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id;

    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return response?['id'];
  }

  Future<List<Map<String, dynamic>>> getMedicalRecordsByProfileId(
      String profileId) async {
    final response = await _supabase
        .from('medical_records')
        .select()
        .eq('profile_id', profileId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchBarChartData(String profileId) async {
  final response = await Supabase.instance.client
      .from('medical_records')
      .select('created_at, blood_glucose_level')
      .eq('profile_id', profileId)
      .order('created_at', ascending: true)
      .limit(30); // ambil 30 data terakhir

  return List<Map<String, dynamic>>.from(response);
}

  

  
}
