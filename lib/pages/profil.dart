import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:train_flutter/pages/Homepage.dart';
import 'package:train_flutter/shared/thame_shared.dart';
import 'package:train_flutter/supabase_service/profil_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

final profilService = ProfilService();

class _ProfilPageState extends State<ProfilPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String? gender;
  bool isLoading = true;
  bool isReadOnly = true;

  @override
  void initState() {
    super.initState();
    fetchAndFillProfile();
  }

  Future<void> fetchAndFillProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final email = profilService.getCurrentUserEmail() ?? '';
      final name = await profilService.getCurrentUserName();
      final gender = await profilService.getCurrentUserGender();
      final age = await profilService.getCurrentUserAge();
      final tinggi = await profilService.getCurrentUserTinggiBadan();
      final berat = await profilService.getCurrentUserBeratBadan();

      setState(() {
        emailController.text = email;
        nameController.text = name ?? '';
        this.gender = gender ?? '';
        ageController.text = age?.toString() ?? '0';
        heightController.text = tinggi?.toString() ?? '0';
        weightController.text = berat?.toString() ?? '0';
      });
    } catch (e) {
      print('Error saat ambil profil: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleReadOnly() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
  }

//   void saveChanges() async {
//   setState(() {
//     isLoading = true; // Mulai loading saat menyimpan perubahan
//   });

//   try {
//     String newEmail = emailController.text;
//     final name = nameController.text;
//     final age = int.tryParse(ageController.text) ?? 0;
//     final tinggiBadan = int.tryParse(heightController.text) ?? 0;
//     final beratBadan = int.tryParse(weightController.text) ?? 0;

//     await profilService.updateEmail(newEmail);
//     final user = Supabase.instance.client.auth.currentUser;
//       if (user == null) {
//         return;
//       }

//       final userId = user.id;

//       // Panggil fungsi updateUserProfile dari ProfilService
//       await profilService.updateUserProfile(
//         userId: userId,
//         name: name,
//         age: age,
//         tinggiBadan: tinggiBadan,
//         beratBadan: beratBadan,
//         gender: gender,
//       );

//     setState(() {
//       isReadOnly = true; // Kembalikan menjadi read-only setelah menyimpan
//     });

//     // Menampilkan notifikasi atau pesan sukses jika berhasil
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Perubahan berhasil disimpan')),
//     );
//   } catch (e) {
//     // Menangani error jika update gagal
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
//     );
//   } finally {
//     setState(() {
//       isLoading = false; // Hentikan loading
//     });
//   }
// }

  void saveChanges() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Nama tidak boleh kosong")),
      );
      return;
    }

    if (ageController.text.isEmpty ||
        int.tryParse(ageController.text) == null ||
        int.tryParse(ageController.text)! <= 0 ||
        ageController.text.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ Umur harus diisi dan tidak boleh 0 atau negatif")),
      );
      return;
    }

    if (heightController.text.isEmpty ||
        int.tryParse(heightController.text) == null ||
        int.tryParse(heightController.text)! < 100 ||
        heightController.text.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "❌ Tinggi badan harus diisi minimal 3 digit dan tidak boleh 0 atau negatif")),
      );
      return;
    }

    if (weightController.text.isEmpty ||
        int.tryParse(weightController.text) == null ||
        int.tryParse(weightController.text)! < 10 ||
        weightController.text.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "❌ Berat badan harus diisi minimal 2 digit dan tidak boleh 0 atau negatif")),
      );
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/ques.png', width: 150, height: 150),
            const SizedBox(height: 4),
            const Text("Anda yakin Melakukan perubahan"),
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
                )),
          ],
        ),
      ),
    );

    if (shouldSave != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final name = nameController.text;
      final age = int.tryParse(ageController.text) ?? 0;
      final tinggiBadan = int.tryParse(heightController.text) ?? 0;
      final beratBadan = int.tryParse(weightController.text) ?? 0;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await profilService.updateUserProfile(
        userId: user.id,
        name: name,
        age: age,
        tinggiBadan: tinggiBadan,
        beratBadan: beratBadan,
        gender: gender,
      );

      setState(() {
        isReadOnly = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        fetchAndFillProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
            title: const Text('Detail Profil'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: toggleReadOnly,
                  child: Image.asset(
                    'assets/edit.png',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.asset(
                      gender == 'female'
                          ? 'assets/woman.png'
                          : 'assets/man.png',
                      width: 130,
                      height: 130,
                    ),
                    const Gap(8),
                    Text(
                      emailController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    // TextFormField(
                    //   controller: emailController,
                    //   readOnly: true,
                    //   decoration: const InputDecoration(
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(8)),
                    //     ),
                    //     labelText: 'Email',
                    //   ),
                    // ),
                    const Gap(16),
                    TextFormField(
                      controller: nameController,
                      readOnly: isReadOnly,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: 'Nama',
                      ),
                    ),
                    const Gap(16),
                    if (isReadOnly)
                      TextFormField(
                        controller: TextEditingController(
                          text: gender == 'male'
                              ? 'Laki-Laki'
                              : (gender == 'female'
                                  ? 'Perempuan'
                                  : 'Pilih Jenis Kelamin'),
                        ),
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          labelText: 'Jenis Kelamin',
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: gender,
                        onChanged: (String? newValue) {
                          setState(() {
                            gender = newValue;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Laki-Laki'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Perempuan'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          labelText: 'Jenis Kelamin',
                        ),
                      ),
                    const Gap(16),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      readOnly: isReadOnly,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: 'Umur',
                      ),
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      readOnly: isReadOnly,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: 'Tinggi Badan (cm)',
                      ),
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      readOnly: isReadOnly,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: 'Berat Badan (kg)',
                      ),
                    ),
                    const Gap(16),
                    if (!isReadOnly)
                      SizedBox(
                        width: screenWidth,
                        child: ElevatedButton(
                          onPressed: saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff078EF4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
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
              ),
            ),
          ),
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
