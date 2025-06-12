import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:train_flutter/auth/auth_service.dart';
import 'package:train_flutter/pages/detailpage.dart';
import 'package:train_flutter/pages/login.dart';
import 'package:train_flutter/pages/predict.dart';
import 'package:train_flutter/pages/profil.dart';
import 'package:train_flutter/shared/thame_shared.dart';
import 'package:train_flutter/supabase_service/profil_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final profilService = ProfilService();
  bool isLoading = false;
  List<Map<String, dynamic>> medicalRecords = [];

  void logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/ques.png', width: 150, height: 150),
            const SizedBox(height: 4),
            const Text("Anda yakin ingin logout?"),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff078EF4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Yakin',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(color: Color(0xff078EF4))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Jika pengguna memilih "Yakin", maka logout dilakukan
    if (shouldLogout != true) return;

    try {
      await authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
      }
    }
  }

  String? currentUserName;
  String? currentUserStatus;
  String? curentUserId;

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
      fetchMedicalRecords();
    });
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    final name = await profilService.getCurrentUserName();
    final status = await authService.getCurrentUserStatus();

    setState(() {
      currentUserName = name ?? 'User';
      currentUserStatus = status ?? 'Unknown';
      isLoading = false;
    });
  }

  Future<void> fetchMedicalRecords() async {
    setState(() {
      isLoading = true;
    });

    final profileId = await profilService.getCurrentProfileId();
    if (profileId == null) return;

    final records = await profilService.getMedicalRecordsByProfileId(profileId);

    records.sort((a, b) {
      final dateA = DateTime.parse(a['created_at']);
      final dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA); // Urutkan dari yang terbaru
    });
    setState(() {
      medicalRecords = records;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Text('Hai ', style: titleTextStyle),
                Text('$currentUserName', style: nameTextStyle),
              ],
            ),
            backgroundColor: const Color(0xFFF2F9FC),
            actions: [
              IconButton(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                iconSize: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilPage()),
                    );
                  },
                  child: Image.asset(
                    'assets/profil.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)],
                ),
              ),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin:  const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit
                              .cover, 
                            
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16), // Padding inside the card
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/cek.png', // Replace with the actual path to your image
                              width: 130, // Set the desired width
                              height: 160, // Set the desired height
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Ayo cek rekomendasi makananmu sekarang',
                                        style: buttonTextStyle, // Your text style
                                        overflow: TextOverflow
                                            .ellipsis, // To handle text overflow
                                        maxLines: 2, 
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PredictForm()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Cek Sekarang', // Button text
                                      style: TextStyle(
                                          fontSize: 16, color: blueColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Kondisi Terakhir',
                        style: smallboldTextStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: medicalRecords.isEmpty
                        ? const Center(
                            child: Text('Tidak ada data medical record.'))
                        : ListView.builder(
                            itemCount: medicalRecords.length,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            itemBuilder: (context, index) {
                              final record = medicalRecords[index];
                              final currentBloodGlucoseLevel = double.tryParse(
                                      record['blood_glucose_level']
                                          .toString()) ??
                                  0;

                              // Format tanggal
                              final date = DateTime.parse(record['created_at']);
                              final formattedDate =
                                  "${date.day.toString().padLeft(2, '0')}/"
                                  "${date.month.toString().padLeft(2, '0')}/"
                                  "${date.year}";

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                          recordId: record['record_id']),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: record['prediction'] == 1
                                      ? const Color(0xFFFFE3E3)
                                      : const Color(0xFFD1FADF),
                                  elevation: 4,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  record['prediction'] == 1
                                                      ? "Kemungkinan terkena diabetes"
                                                      : "Tidak ada indikasi diabetes",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54),
                                                ),
                                                const Gap(12),
                                              ],
                                            ),
                                            Text(
                                              'Gula Darah $currentBloodGlucoseLevel mg/dL',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => const PredictForm()),
          //     );
          //   },
          //   backgroundColor: blueColor,
          //   foregroundColor: Colors.white,
          //   child: const Icon(Icons.add),
          // ),
        ),
        if (isLoading)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
