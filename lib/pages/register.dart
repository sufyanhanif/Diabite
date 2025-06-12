import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:train_flutter/pages/login.dart';
import 'package:train_flutter/pages/verifikasi_email.dart';
import 'package:train_flutter/shared/thame_shared.dart';
import 'package:train_flutter/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //get auth service
  final authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  var _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    void signup() async {
      //prepare data

      final email = _emailController.text;
      final password = _passwordController.text;
      final name = _nameController.text;
      final confirmPassword = _confirmpasswordController.text;

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Password Wrong")));
        return;
      }

      try {
        await authService.signUpWithEmailPassword(email, password, name);

        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const VerifPage()));

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
                      "Cek Email",
                      style: smallTextStyle,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog
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
        }
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
                    Text(
                      "Gagal mendaftar",
                      style: smallTextStyle,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog
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
        }
      }
    }

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
              SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultMargin,
                    ),
                    children: [
                      Column(
                        children: [
                          const Gap(100),
                          Text(
                            'Register',
                            style: mediumTextStyle,
                          ),
                          const Gap(12),
                          Text(
                            'Input your email, password and name',
                            style: smallTextStyle,
                          ),
                          const Gap(36),

                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              labelText: 'Name',
                            ),
                          ),
                          const Gap(24),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              labelText: 'Email',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                !EmailValidator.validate(value!)
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
                          const Gap(24),
                          TextFormField(
                            controller: _confirmpasswordController,
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              labelText: 'Confirm Password',
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
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xffB34960), width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xffB34960), width: 2),
                              ),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Password does not match';
                              }
                              return null;
                            },
                          ),
                          const Gap(12),

                          const Gap(24),
                          //login
                          SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: signup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color(0xff078EF4), // Warna tombol
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corner
                                ),
                              ),
                              child: const Text(
                                'Register',
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
                                  'Have account?',
                                  style: smallTextStyle,
                                ),
                                const Gap(8),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      )),
                                  child: Center(
                                    child: Text(
                                      "Sign In",
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
                  ))
            ],
          )),
    );
  }
}
