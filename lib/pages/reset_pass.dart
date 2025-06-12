import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:train_flutter/pages/forgot_password.dart';
import 'package:train_flutter/pages/login.dart';
import 'package:train_flutter/shared/thame_shared.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  var _passwordVisible = true;

  void reset_pass() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final token = _tokenController.text;

    try {
      final recovery = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      print(recovery); // Memeriksa apakah hasil verifikasi berhasil

      // Jika OTP valid, lanjutkan dengan update password jika diperlukan
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      // Menampilkan notifikasi sukses setelah update password

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
                  "Berhasil dirubah",
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
                            builder: (context) =>
                                const LoginPage()), // Pastikan ProfilePage sudah diimport
                      ); // Tutup dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff078EF4), // Warna tombol
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corner
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
    } catch (e) {
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
                  const Text(
                    "Terjadi kesalahan. Coba lagi.",
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
                        backgroundColor: const Color(0xff078EF4), // Button color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
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
                      'Reset Password',
                      style: mediumTextStyle,
                    ),
                    const Gap(12),
                    Text(
                      'Input your token, email, and password',
                      style: smallTextStyle,
                    ),
                    const Gap(36),
                    TextFormField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        labelText: 'Token',
                      ),
                    ),
                    const Gap(24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        labelText: 'Email',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => !EmailValidator.validate(value!)
                          ? 'Format Email Salah!'
                          : null,
                    ),
                    const Gap(24),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          labelText: 'New Password',
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
                    const Gap(24),
                    SizedBox(
                      width:
                          screenWidth, // Pastikan screenWidth sesuai dengan ukuran layar
                      child: ElevatedButton(
                        onPressed: reset_pass,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff078EF4), // Warna tombol
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corner
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                              const ForgotPasswordPage()), // Pastikan ProfilePage sudah diimport
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
