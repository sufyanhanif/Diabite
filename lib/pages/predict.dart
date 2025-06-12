import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:train_flutter/pages/Homepage.dart';
import 'package:train_flutter/pages/detailpage.dart';
import 'package:train_flutter/shared/thame_shared.dart';
import 'package:train_flutter/supabase_service/profil_service.dart';

class PredictForm extends StatefulWidget {
  const PredictForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PredictFormState createState() => _PredictFormState();
}

class _PredictFormState extends State<PredictForm> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final profilService = ProfilService();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();

  String? gender;
  int hypertension = 0;
  int historyDiabet = 0;
  String predictionResult = '';
  String nameResult = '';
  String activityResult = '';
  int activity = 1;
  bool isLoading = false;
  String? recordId;
  double kalori = 0;
  double bmi = 0;


  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    setState(() {
      isLoading = true;
    });

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final age = await profilService.getCurrentUserAge();
    final genderValue = await profilService.getCurrentUserGender();
    final height = await profilService.getCurrentUserTinggiBadan();
    final weight = await profilService.getCurrentUserBeratBadan();

    setState(() {
      ageController.text = age?.toString() ?? '';
      gender = genderValue;
      heightController.text = height?.toString() ?? '';
      weightController.text = weight?.toString() ?? '';
      isLoading = false;
    });
  }

  Future<void> saveDataAndPredict(dynamic sugarController) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Tidak ada pengguna yang login")),
      );
      return;
    }

    final userId = user.id;

    if (sugarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Field GDS harus diisi")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      predictionResult = '';
      nameResult = '';
    });


    final int glucoseLevel = int.tryParse(sugarController.text) ?? 0;
    final int age = int.tryParse(ageController.text) ?? 0;
    final int height = int.tryParse(heightController.text) ?? 0;
    final int weight = int.tryParse(weightController.text) ?? 0;

    final Map<String, dynamic> requestData = {
      "age": age,
      "gender": gender,
      "hypertension": hypertension,
      "riwayat_diabetes": historyDiabet,
      "gds": glucoseLevel,
      "height": height,
      "weight": weight,
      "activity_level": activity,
    };

    final url =
        Uri.parse('https://predictdb-fad2b0d716d3.herokuapp.com/predict');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (!data.containsKey('prediction')) {
          throw Exception("Response tidak mengandung 'prediction'");
        }

        var prediction = data['prediction'];
        String hasil = (prediction == 0) ? "Negative" : "Positive";
        var recommendFood = data['recommend_food'];
        nameResult = (recommendFood != null && recommendFood.isNotEmpty)
            ? recommendFood[0]['name']
            : 'No food recommendation available';
        var activityRecommend = data['activity'];
        activityResult = activityRecommend;
        var kaloriRecommend = data['calculate_kal'];
        kalori = (kaloriRecommend as num).toDouble();
        var bmiResult = data['bmi'];
        bmi = (bmiResult as num).toDouble();

        // Simpan semua data ke medical_records
        final insertResponse = await _supabase
            .from('medical_records')
            .insert({
              'profile_id': userId,
              'age': age,
              'gender': gender,
              'weight': weight,
              'height': height,
              'hypertension': hypertension,
              'riwayat_diabetes': historyDiabet,
              'blood_glucose_level': glucoseLevel,
              'prediction': prediction,
              'prefrensi_food': nameResult,
              'activity': activityResult,
              'kalori': kalori,
              'bmi': bmi,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('record_id')
            .maybeSingle();

        if (insertResponse != null && insertResponse['record_id'] != null) {
          recordId = insertResponse['record_id'];
        }

        await _supabase.from('profiles').update({
          'hasil': hasil,
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
        }).eq('id', userId);

        // Update form fields with the new data
        setState(() {
          ageController.text = age.toString();
          heightController.text = height.toString();
          weightController.text = weight.toString();
          gender = gender;
          predictionResult = "Hasil Prediksi: $hasil";
          isLoading = false;
        });

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(recordId: recordId!),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Prediksi berhasil: $hasil")),
        );
      } else {
        setState(() {
          predictionResult = "❌ Gagal mendapatkan prediksi\n"
              "Status Code: ${response.statusCode}\n"
              "Response: ${response.body}";
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() {
        predictionResult = "❌ Error menghubungkan ke API: $e";
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

   void showPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Cek Gula Darah',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/glucose.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 10),
              // Deskripsi
              const Text(
                'Anda dapat mengecek gula darah menggunakan blood glucose meter kapanpun',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Button untuk "Next"
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  showNextPopup(context); // Menampilkan popup selanjutnya
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: blueColor,
                ),
                child: Text('Next', style : buttonTextStyle),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showNextPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Cek Hipertensi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/hiper.png', 
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 10),
              // Deskripsi
              const Text(
                'Jika tekanan darah lebih dari 140 mmHg dan mengalami sakit kepala, riwayat hipertensi bisa pilih opsi Ya',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: blueColor,
                ),
                child: Text('Saya Mengerti', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              backgroundColor: const Color(0xFFF2F9FC),
              title: const Text("Cek Rekomendasi"),
              actions: [
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () => showPopup(context), 
                  child: Image.asset(
                    'assets/info.png',
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
              height: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // INPUTS
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: gender,
                    onChanged: (String? newValue) {
                      setState(() {
                        gender = newValue;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Laki-Laki')),
                      DropdownMenuItem(
                          value: 'female', child: Text('Perempuan')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: 'Jenis Kelamin',
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Weight (kg)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Height (cm)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                   TextField(
                    controller: glucoseController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Gula Darah",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: hypertension,
                    onChanged: (int? newValue) {
                      setState(() {
                        hypertension = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Tidak')),
                      DropdownMenuItem(value: 1, child: Text('Ya')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: 'hypertension',
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: historyDiabet,
                    onChanged: (int? newValue) {
                      setState(() {
                        historyDiabet = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Tidak')),
                      DropdownMenuItem(value: 1, child: Text('Ya')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: 'Riwayat Diabetes',
                    ),
                  ),
                  const SizedBox(height: 12),

                 

                  

                  DropdownButtonFormField<int>(
                    value: activity,
                    onChanged: (int? newValue) {
                      setState(() {
                        activity = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 1,
                          child: Text('Minimal bergerak/ Pekerja kantoran')),
                      DropdownMenuItem(
                          value: 2,
                          child: Text('Aktivitas ringan (1-3 hari/minggu)')),
                      DropdownMenuItem(
                          value: 3,
                          child: Text('Aktivitas moderat (3-5 hari/minggu)')),
                      DropdownMenuItem(
                          value: 4,
                          child: Text('Aktivitas berat (6-7 hari/minggu)')),
                      DropdownMenuItem(
                          value: 5, child: Text('Aktivitas atlit')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: 'Activity',
                    ),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => saveDataAndPredict(glucoseController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff078EF4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Prediksi & Simpan Data",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (predictionResult.isNotEmpty)
                    Card(
                      color: Colors.blue[50],
                      elevation: 2,
                      margin: const EdgeInsets.only(top: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            predictionResult,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (activityResult.isNotEmpty)
                    Card(
                      color: Colors.blue[50],
                      elevation: 2,
                      margin: const EdgeInsets.only(top: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            activityResult,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Overlay loading screen
        if (isLoading)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)],
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
