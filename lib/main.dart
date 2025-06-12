import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:train_flutter/pages/Homepage.dart';
import 'package:train_flutter/pages/admin/adminpage.dart';
import 'package:train_flutter/pages/welcome.dart';

void main() async {
  //supabase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://whaqpdopmoaovkqatdtu.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoYXFwZG9wbW9hb3ZrcWF0ZHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1ODY4MDcsImV4cCI6MjA2MjE2MjgwN30.hanRnXupGXlPCJKrU1-Ql0b8cYwuqx8yPorKeOG3q6Q",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: Supabase.instance.client.auth.onAuthStateChange,
//         builder: (context, snapshot) {
//           //loading
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           //check

//           final session = snapshot.hasData ? snapshot.data!.session : null;

//           if (session != null) {
//             return const HomePage();
//           } else {
//             return const WelcomePage();
//           }
//         });
//   }
// }

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Fungsi untuk cek status pengguna aktif
  Future<bool> isUserActive() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('status')
        .eq('id', user.id)
        .maybeSingle();

    final status = response?['status'];
    return status == 'active';
  }

  // Fungsi untuk cek role pengguna
  Future<String?> getUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return response?['role'];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // Cek status user sebelum masuk ke halaman yang sesuai
          return FutureBuilder<bool>(
            future: isUserActive(),
            builder: (context, statusSnapshot) {
              if (!statusSnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (statusSnapshot.data == true) {
                // Cek role user dan arahkan ke halaman yang sesuai
                return FutureBuilder<String?>(
                  future: getUserRole(),
                  builder: (context, roleSnapshot) {
                    if (!roleSnapshot.hasData) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }


                    if (roleSnapshot.data == 'admin') {
                      return const AdminPage();
                    } else {
                      return const HomePage();
                    }
                  },
                );
              } else {
                Supabase.instance.client.auth.signOut();
                return const WelcomePage(); 
              }
            },
          );
        } else {
          return const WelcomePage(); 
        }
      },
    );
  }
}
