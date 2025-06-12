import 'package:flutter/material.dart';
import 'package:train_flutter/pages/login.dart';
import 'package:train_flutter/pages/register.dart';
import 'package:train_flutter/shared/thame_shared.dart';
import 'package:gap/gap.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar menggunakan MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25), 
                          child: Image.asset(
                            'assets/vector.png',
                            width: screenWidth *
                                0.8, 
                            height: screenHeight *
                                0.4, 
                            fit: BoxFit
                                .contain, 
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'Selamat datang di Diabite',
                          style: mediumTextStyle,
                        ),
                        const Gap(8),
                        Text(
                          'Rekomendasi Makanan untuk Mengontrol Gula Darah',
                          style: smallTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(32),
                        //button login
                        SizedBox(
                          width: screenWidth,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginPage()), 
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xff078EF4), // Warna tombol
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
                        const Gap(16),
                        SizedBox(
                          width: screenWidth,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                  color: Color(0xff078EF4), width: 3),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12), 
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Color(0xff078EF4),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )));
  }
}
