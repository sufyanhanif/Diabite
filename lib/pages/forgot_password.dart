import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:train_flutter/pages/login.dart';
import 'package:train_flutter/pages/reset_pass.dart';
import 'package:train_flutter/shared/thame_shared.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  
  void sendResetPasswordToken() async {
    // Prepare data

    final email = _emailController.text;

    try {
      // Trigger the reset password action
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text(
                'Check your Email',
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          // ignore: use_build_context_synchronously
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
                  const Gap(12),
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
                              BorderRadius.circular(12), 
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
                padding: EdgeInsets.symmetric(
                  horizontal: defaultMargin,
                ),
                children: [
                  Column(
                    children: [
                      const Gap(160),
                      Text(
                        'Reset Password',
                        style: mediumTextStyle,
                      ),
                      const Gap(12),
                      Text(
                        'Input your email to get token',
                        style: smallTextStyle,
                      ),
                      const Gap(36),
                      TextFormField(
                        controller: _emailController,
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
                      //send email
                      SizedBox(
                        width: screenWidth,
                        child: ElevatedButton(
                          onPressed: sendResetPasswordToken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff078EF4), // Warna tombol
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // Rounded corner
                            ),
                          ),
                          child: const Text(
                            'Send',
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
                              'received the token',
                              style: smallTextStyle,
                            ),
                            const Gap(8),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResetPassPage(),
                                  )),
                              child: Center(
                                child: Text(
                                  "Reset Password",
                                  style: bluesmallTextStyle,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
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
                                        const LoginPage()), // Pastikan ProfilePage sudah diimport
                              );
                          },
                        ),
                      ),
            ],
          )),
    );
  }
}
