import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:train_flutter/pages/login.dart';
import 'package:train_flutter/pages/register.dart';
import 'package:train_flutter/shared/thame_shared.dart';

class VerifPage extends StatefulWidget {
  final String name;
  final String email;

  const VerifPage({super.key, required this.name, required this.email});

  @override
  State<VerifPage> createState() => _VerifPageState();
}

class _VerifPageState extends State<VerifPage> {
  final tokenController = TextEditingController();
  final emailController =
      TextEditingController(); // Tambahkan controller untuk email
  
  // ignore: non_constant_identifier_names


  void verifEmail() async {

    final token = tokenController.text;
    final email = emailController.text;

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Email tidak boleh kosong")),
      );
      return;
    }

    if (tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Token tidak boleh kosong")),
      );
      return;
    }

    try {
      // Melakukan verifikasi OTP dengan email
      await Supabase.instance.client.auth.verifyOTP(
        token: token,
        type: OtpType.signup, // Pastikan tipe OTP sesuai
        email: email, // Sertakan email untuk verifikasi
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'name': widget.name, // Menggunakan name yang diteruskan
          'email': email, // Menggunakan email yang diteruskan
          'gender': 'male', // Sesuaikan dengan data yang Anda inginkan
          'weight': 0,
          'height': 0,
          'age': 0,
          'role': 'user',
          'status': 'active',
        });

        // Menampilkan dialog sukses
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/berhasil.png', width: 150, height: 150),
                  const SizedBox(height: 4),
                  Text(
                    "Berhasil Terdaftar Silahkan Login",
                    style: smallTextStyle,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff078EF4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      // Tangani kesalahan di sini
      String errorMessage = 'Terjadi kesalahan. Coba lagi.';
      if (e is AuthException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Terjadi kesalahan yang tidak diketahui: $e';
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/gagal.png', width: 150, height: 150),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff078EF4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Future<void> resendOTP() async {
    final email = emailController.text;
    try {
      await Supabase.instance.client.auth
          .resend(type: OtpType.signup, email: email);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/berhasil.png', width: 150, height: 150),
                  const SizedBox(height: 4),
                  const Text(
                    "OTP telah dikirim ulang. Cek email Anda.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff078EF4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      // Menangani error jika pengiriman OTP gagal
      String errorMessage = 'Terjadi kesalahan. Coba lagi.';
      if (e is AuthException) {
        errorMessage = e.message;
      }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/gagal.png', width: 150, height: 150),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff078EF4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ok',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
  void initState() {
    super.initState();
    emailController.text = widget.email; 
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                padding: EdgeInsets.symmetric(horizontal: defaultMargin),
                children: [
                  Column(children: [
                    const Gap(150),
                    Text(
                      'Verifikasi Email',
                      style: mediumTextStyle,
                    ),
                    const Gap(12),
                    Text(
                      'Masukan email dan token',
                      style: smallTextStyle,
                    ),
                    const Gap(36),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        labelText: 'Email',
                      ),
                    ),
                    const Gap(24),
                    TextFormField(
                      controller: tokenController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        labelText: 'Token',
                      ),
                    ),
                    const Gap(24),
                    SizedBox(
                      width:
                          screenWidth, // Pastikan screenWidth sesuai dengan ukuran layar
                      child: ElevatedButton(
                        onPressed: verifEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff078EF4), // Warna tombol
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corner
                          ),
                        ),
                        child: const Text(
                          'Kirim Token',
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
                            'Token tidak terkirim?',
                            style: smallTextStyle,
                          ),
                          const Gap(8),
                          GestureDetector(
                            onTap: resendOTP,
                            child: Center(
                              child: Text(
                                "Kirim ulang",
                                style: bluesmallTextStyle,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ]),
                ],
              ),
              Positioned(
                top: 30,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const RegisterPage()), 
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
