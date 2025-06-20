import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:train_flutter/pages/homepage.dart';
import 'package:train_flutter/shared/thame_shared.dart';
import 'package:train_flutter/supabase_service/detail_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final String recordId;

  const DetailPage({super.key, required this.recordId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLoading = false;
  Map<String, dynamic>? recordDetail;
  String dropdownValueJenis = 'Sayuran';
  List<Map<String, dynamic>> rekomResult = [];

  String getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Kekurangan berat badan';
    } else if (bmi < 25) {
      return 'Berat badan ideal';
    } else if (bmi < 30) {
      return 'Kelebihan berat badan';
    } else {
      return 'Obesitas';
    }
  }

  Widget getFoodImage(String jenis) {
    switch (jenis) {
      case 'Sayuran':
        return Image.asset(
          'assets/sayur.png',
          width: 200,
          height: 200,
        );
      case 'Daging':
        return Image.asset(
          'assets/meat.png',
          width: 200,
          height: 200,
        );
      case 'Ikan & Seafood':
        return Image.asset(
          'assets/ikan.png',
          width: 200,
          height: 200,
        );
      case 'Kacang-Kacangan':
        return Image.asset(
          'assets/kacang.png',
          width: 200,
          height: 200,
        );
      case 'Buah':
        return Image.asset(
          'assets/buah.png',
          width: 200,
          height: 200,
        );
      case 'Sup':
        return Image.asset(
          'assets/sup.png',
          width: 200,
          height: 200,
        );
      case 'Telur':
        return Image.asset(
          'assets/egg.png',
          width: 200,
          height: 200,
        );
      default:
        return Image.asset(
          'assets/roti.png',
          width: 200,
          height: 200,
        );
    }
  }

  // Function to fetch food recommendations
  Future<void> recommendFood(String nameResult) async {
    final url =
        Uri.parse('https://rfoodb-c6321cc8dca8.herokuapp.com/recommendations');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item_name': nameResult,
        'food_type': dropdownValueJenis,
        'top_n': 3
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        var recommendFood = data['recommend_food'] as List<dynamic>;
        if (recommendFood.isNotEmpty) {
          rekomResult = recommendFood.take(3).map((food) {
            return {
              'name': food['name'],
              'jenis': food['jenis'],
              'kalori': food['kalori'],
              'karbohidrat': food['karbohidrat'],
              'lemak': food['lemak'],
              'protein': food['protein']
            };
          }).toList();
        } else {
          rekomResult = [];
        }
      });
    } else {
      setState(() {
        rekomResult = [];
      });
    }
  }

  var detailService = DetailService();

  @override
  void initState() {
    super.initState();
    fetchRecordDetail();
  }

  // Fetch medical record details by recordId
  Future<void> fetchRecordDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the medical records based on the recordId passed
      final records =
          await detailService.getMedicalRecordsByRecordId(widget.recordId);
      if (records.isNotEmpty) {
        setState(() {
          recordDetail = records.first;
        });
        // After getting record detail, recommend food
        String nameResult = recordDetail!['prefrensi_food'] ??
            'DefaultName'; // Replace with the correct key
        recommendFood(nameResult);
      } else {
        setState(() {
          recordDetail = null;
        });
      }
    } catch (e) {
      setState(() {
        recordDetail = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteRecord() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/ques.png', width: 150, height: 150),
            const SizedBox(height: 4),
            const Text("Anda yakin ingin menghapus record ini?"),
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

    // If user chose "No", stop the delete operation
    if (shouldDelete != true) return;

    // Start loading
    setState(() {
      isLoading = true;
    });

    try {
      // Menghapus record
      await detailService.deleteMedicalRecord(widget.recordId);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record berhasil dihapus')),
      );

      // Navigate back to the homepage after deletion
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      // Handle any errors during deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $e')),
      );
    } finally {
      // Stop loading
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        title: const Text('Detail Rekaman Medis'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: deleteRecord,
              child: Image.asset(
                'assets/hapus.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFFF2F9FC),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)]),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16.0), // Menambahkan padding
                children: [
                  if (recordDetail != null) ...[
                    Card(
                      color: primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Diagnosa',
                                      style: smalllowTextStyle,
                                    ),
                                    const Gap(8), //
                                    Image.asset(
                                      'assets/heart.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                                Text(
                                  recordDetail!['created_at'] != null
                                      ? () {
                                          final date = DateTime.parse(
                                              recordDetail!['created_at']);
                                          final formattedDate =
                                              "${date.day.toString().padLeft(2, '0')}/"
                                              "${date.month.toString().padLeft(2, '0')}/"
                                              "${date.year}";
                                          return formattedDate;
                                        }()
                                      : 'Data tidak tersedia',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              '${recordDetail!['prediction'] == 1 ? 'Kemungkinan terkena diabetes' : recordDetail!['prediction'] == 0 ? 'Tidak terkena diabetes' : 'Data tidak tersedia'}',
                              style: smallTextStyle,
                            ),
                            const Gap(8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        'Gula Darah: ${recordDetail!['blood_glucose_level'] ?? 'Data tidak tersedia'}'),
                                    const Gap(8),
                                    Text(
                                        'Umur: ${recordDetail!['age'] ?? 'Data tidak tersedia'}'),
                                    const Gap(16),
                                  ],
                                ),
                                const Gap(8),
                                Row(
                                  children: [
                                    Text(
                                        'Riwayat Hipertensi: ${recordDetail!['hypertension'] == 1 ? 'Iya' : recordDetail!['hypertension'] == 0 ? 'Tidak' : 'Data tidak tersedia'}'),
                                    const Gap(8),
                                    Text(
                                        'Riwayat Diabetes: ${recordDetail!['riwayat_diabetes'] == 1 ? 'Iya' : recordDetail!['riwayat_diabetes'] == 0 ? 'Tidak' : 'Data tidak tersedia'}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    Card(
                      color: primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kondisi tubuh',
                                  style: smalllowTextStyle,
                                ),
                                const Gap(8),
                                Image.asset(
                                  'assets/bmi.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                            const Gap(8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recordDetail!['bmi'] != null
                                      ? 'BMI: ${recordDetail!['bmi'].toStringAsFixed(1)}'
                                      : 'BMI: Data tidak tersedia',
                                  style: smallTextStyle,
                                ),
                                const Gap(4),
                                if (recordDetail!['bmi'] != null)
                                  Text(
                                    'Kategori: ${getBmiCategory(recordDetail!['bmi'])}',
                                    style: smallTextStyle,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),
                    Card(
                      color: primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kalori yang dibutuhkan',
                                  style: smalllowTextStyle,
                                ),
                                const Gap(8),
                                Image.asset(
                                  'assets/kalori.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              '${recordDetail!['kalori'] ?? 'Data tidak tersedia'} Kalori per hari',
                              style: smallTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),
                    
                    Card(
                      color: Colors
                          .white, // Atau ganti dengan warna seperti Color(0xFFF2F9FC)
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Rekomendasi Makanan',
                                  style: smalllowTextStyle,
                                ),
                                const Gap(8), //
                                Image.asset(
                                  'assets/food.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                            const Gap(16),
                            DropdownButtonFormField<String>(
                              value: dropdownValueJenis,
                              items: recordDetail!['prediction'] == 1
                                      ? [
                                          'Sayuran',
                                          'Buah',
                                          'Kacang-Kacangan',
                                          'Ikan & Seafood',
                                          'Telur'
                                        ]
                                          .map((value) => DropdownMenuItem(
                                                value: value,
                                                child: Text(value),
                                              ))
                                          .toList()
                                      : [
                                          'Sayuran',
                                          'Buah',
                                          'Kacang-Kacangan',
                                          'Ikan & Seafood',
                                          'Telur',
                                          'Sup',
                                          'Roti & Sereal',
                                          'Daging'
                                        ]
                                          .map((value) => DropdownMenuItem(
                                                value: value,
                                                child: Text(value),
                                              ))
                                          .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  dropdownValueJenis = newValue!;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Pilih Jenis Makanan',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const Gap(16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => recommendFood(
                                    recordDetail!['prefrensi_food'] ??
                                        'DefaultName'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff078EF4),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Ubah Jenis Makanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                            rekomResult.isNotEmpty
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: rekomResult.map<Widget>((food) {
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          elevation: 4.0,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                getFoodImage(food['jenis']),
                                                const Gap(16),
                                                Text(
                                                  food['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                ),
                                                Text(
                                                    'Kalori: ${food['kalori']} kcal'),
                                                Text(
                                                    'Karbohidrat: ${food['karbohidrat']} g'),
                                                Text(
                                                    'Protein: ${food['protein']} g'),
                                                Text(
                                                    'Lemak: ${food['lemak']} g'),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : const Text(
                                    'No food recommendation available',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    Card(
                      color: primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Rekomendasi Aktivitas',
                                  style: smalllowTextStyle,
                                ),
                                const Gap(8),
                                Image.asset(
                                  'assets/olahraga.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              ' ${recordDetail!['activity'] ?? 'Data tidak tersedia'}',
                              style: smallTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    if (recordDetail!['prediction'] == 1) ...[
                      Card(
                        color: primaryColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Saran Pengolahan',
                                    style: smalllowTextStyle,
                                  ),
                                  const Gap(8),
                                  Image.asset(
                                    'assets/olah.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Text(
                                'Olah makanan dengan cara direbus, dikukus, atau dipanggang. Kurangi penggunaan gula dan garam.',
                                style: smallTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          // Indikator loading di atas konten
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
      ),
    );
  }
}
