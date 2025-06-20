import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:train_flutter/auth/auth_service.dart';
import 'package:train_flutter/pages/Homepage.dart';
import 'package:train_flutter/pages/admin/adminpage.dart';
import 'package:train_flutter/pages/forgot_password.dart';
import 'package:train_flutter/pages/register.dart';
import 'package:train_flutter/shared/thame_shared.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

  

class _LoginPageState extends State<LoginPage> {
  //get auth service
  final authService = AuthService();

  //text Controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var _passwordVisible = true;


// void login() async {
//   final email = emailController.text;
//   final password = passwordController.text;

//   try {
    

//     if (email.isEmpty || password.isEmpty) {
//       throw Exception("Email atau password tidak boleh kosong.");
//     }

//     final response = await authService.signInWithEmailPassword(email, password);


//     final user = response?.user;
    
    

//     // Jika user berhasil login, lanjutkan ke HomePage
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomePage()),
//       );
//     }

   

//     // Dialog Sukses
//     if (mounted) {
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset('assets/berhasil.png', width: 150, height: 150),
//                 const SizedBox(height: 4),
//                 Text("Selamat Datang ${user?.email}", style: smallTextStyle),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context); // Tutup dialog
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xff078EF4),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text('Ok', style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }

//   } catch (e) {
//     String errorMessage = e.toString();
    
//     // Hapus "Exception: " agar pesan lebih bersih
//     errorMessage = errorMessage.replaceAll("Exception:", "").trim();

//     if (mounted) {
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset('assets/gagal.png', width: 150, height: 150),
//                 const SizedBox(height: 4),
//                 Text(
//                     errorMessage, // Pesan error yang sudah dibersihkan
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context); // Tetap di halaman login
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xff078EF4),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text('Ok', style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
// }

void login() async {
  final email = emailController.text;
  final password = passwordController.text;

  if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Email tidak boleh kosong")),
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Password tidak boleh kosong")),
      );
      return;
    }

  try {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email atau password tidak boleh kosong.");
    }

    final response = await authService.signInWithEmailPassword(email, password);
    final user = response?.user;

    if (user != null) {
      
       final status = await authService.getCurrentUserStatus();

      if (status?.toLowerCase() != 'active') {
        await authService.signOut();
        throw Exception("Akun Anda Sedang Dinonaktifkan.");
      }
      final role = await authService.getCurrentUserRole();

      if (role != null) {
        if (mounted) {
          // Berdasarkan role, arahkan ke halaman yang sesuai
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }

        // Dialog Sukses
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/berhasil.png', width: 150, height: 150),
                    const SizedBox(height: 4),
                    Text("Selamat Datang ${user.email}", style: smallTextStyle),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff078EF4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Ok', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      } else {
        throw Exception("Role pengguna tidak ditemukan.");
      }
    }

  } catch (e) {
    String errorMessage = e.toString();

    // Hapus "Exception: " agar pesan lebih bersih
    errorMessage = errorMessage.replaceAll("Exception:", "").trim();

    if (mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/gagal.png', width: 150, height: 150),
                const SizedBox(height: 4),
                Text(
                    errorMessage, // Pesan error yang sudah dibersihkan
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tetap di halaman login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff078EF4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ok', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)]),
                ),
              ),
              ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultMargin,
                ),
                children: [
                  Column(
                    children: [
                      const Gap(150),
                      Text(
                        'Login',
                        style: mediumTextStyle,
                      ),
                      const Gap(12),
                      Text(
                        'Masukan email dan password',
                        style: smallTextStyle,
                      ),
                      const Gap(36),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          labelText: 'Email',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => !EmailValidator.validate(value!)
                            ? 'Format Email Salah!'
                            : null,
                      ),
                      const Gap(24),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _passwordVisible,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            )),
                      ),
                      const Gap(8),

                       GestureDetector(
                         onTap: () => Navigator.pushReplacement(
                           context,
                           MaterialPageRoute(
                             builder: (context) => const ForgotPasswordPage()),
                       ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right:
                                  16.0), // Beri padding agar tidak menempel ke tepi layar
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end, // Menggeser ke kanan
                            children: [
                              Text("Lupa Password?",
                                  style: bluesmallTextStyle),
                            ],
                          ),
                        ),
                      ),

                      const Gap(24),
                      //login
                      SizedBox(
                        width: screenWidth,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff078EF4), // Warna tombol
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // Rounded corner
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Gap(24),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tidak punya akun?',
                              style: smallTextStyle,
                            ),
                            const Gap(8),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  )),
                              child: Center(
                                child: Text(
                                  "Daftar",
                                  style: bluesmallTextStyle,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          )),
    );
  }
}
