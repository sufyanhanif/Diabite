import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //sign in
  Future<AuthResponse?> signInWithEmailPassword(
      String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login failed: User not found');
      }

      return response;
    } catch (e) {
      await _supabase.auth.signOut();
      throw Exception('$e');
    }
  }

  //Register
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'name': name,
          'email': email,
          'gender': 'male',
          'weight': 0,
          'height': 0,
          'age': 0,
          'role': 'user',
          'status': 'active'
        });

        print('User registered successfully: Name: $name');
      }

      return response;
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      // final user = _supabase.auth.currentUser;
      // if (user != null) {
      //   // Hapus session ID dari database saat logout
      //   await _supabase.from('profiles').update({
      //     'last_session_id': null,
      //   }).eq('id', user.id);
      // }

      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('$e');
    }
  }

  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<User?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;

    if (session != null) {
      final user = session.user;
      return user;
    } else {
      return null;
    }
  }

  Future<String?> getCurrentUserName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.id; // Ambil ID pengguna (UUID)

    final response = await _supabase
        .from('profiles')
        .select('name')
        .eq('id', userId)
        .maybeSingle();

    return response?['name'];
  }

  Future<String?> getCurrentUserStatus() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('profiles')
        .select('status')
        .eq('id', user.id)
        .single();

    return response['status'];
  }

  Future<String?> getCurrentUserRole() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null; 
    }

      final response = await _supabase
          .from('profiles')
          .select('role') 
          .eq('id', user.id) 
          .single(); 

      return response['role'];
  
  }

  
  Future<String?> getCurrentUserHasil() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null; 
    }

      final response = await _supabase
          .from('profiles')
          .select('hasil') 
          .eq('id', user.id) 
          .single(); 

      return response['hasil'];
  
  }
}
