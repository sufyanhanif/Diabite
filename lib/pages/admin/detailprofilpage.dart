import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:train_flutter/pages/admin/userpage.dart';
import 'package:train_flutter/supabase_service/admin_service.dart';

class DetailProfilPage extends StatefulWidget {
  final String userId;

  const DetailProfilPage({super.key, required this.userId});

  @override
  State<DetailProfilPage> createState() => _DetailProfilPageState();
}

final adminService = AdminService();

class _DetailProfilPageState extends State<DetailProfilPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _tbController = TextEditingController();
  final _rbController = TextEditingController();
  final _emailController = TextEditingController();

  String? gender;
  String? status;
  bool isLoading = true;
  bool isReadOnly = true;
  Map<String, dynamic>? userDetail; // Make userDetail nullable
  List<Map<String, dynamic>> diabetesHistory = []; // Store the diabetes history

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
    _fetchDiabetesHistory();
  }

  // Fetch the user's details
  Future<void> _fetchUserDetail() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = await adminService
          .getUserDetails(widget.userId); // Fetch user data based on ID
      setState(() {
        userDetail = user;
        _nameController.text = user['name'] ?? '';
        _ageController.text = user['age']?.toString() ?? '';
        _tbController.text = user['height']?.toString() ?? '';
        _rbController.text = user['weight']?.toString() ?? '';
        _emailController.text = user['email']?.toString() ?? '';
        gender = user['gender'];
        status = user['status'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error here
    }
  }

  // Fetch the diabetes history for the user
  Future<void> _fetchDiabetesHistory() async {
    try {
      final records =
          await adminService.getMedicalRecordsByRecordId(widget.userId);
      setState(() {
        diabetesHistory = records; // Update the diabetes history
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error here
    }
  }

  // Function to save changes
  void saveChanges() async {
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
                          backgroundColor: const Color(0xff078EF4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.white)),
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
      final name = _nameController.text;
      final age = int.tryParse(_ageController.text) ?? 0;
      final tinggiBadan = int.tryParse(_tbController.text) ?? 0;
      final beratBadan = int.tryParse(_rbController.text) ?? 0;

      final userId = widget.userId;

      await adminService.updateUserProfile(
        userId: userId,
        name: name,
        age: age,
        tinggiBadan: tinggiBadan,
        beratBadan: beratBadan,
        gender: gender,
        status: status,
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
        _fetchUserDetail(); // Re-fetch user details to show updated data
      });
    }
  }

  void toggleReadOnly() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserPage()),
            );
          },
        ),
        title: const Text('Detail Pengguna'),
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
        backgroundColor: const Color(0xffF2F9FC),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)],
              ),
            ),
            height: double.infinity,
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Image.asset(
                gender == 'female' ? 'assets/woman.png' : 'assets/man.png',
                width: 130,
                height: 130,
              ),
              const Gap(8),
              Center(
                child: Text(
                  _emailController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                readOnly: isReadOnly,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Nama',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                readOnly: isReadOnly,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Umur',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tbController,
                readOnly: isReadOnly,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Tinggi Badan (cm)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rbController,
                readOnly: isReadOnly,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Berat Badan (kg)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              if (isReadOnly)
                // Display gender as TextFormField (read-only)
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
              const SizedBox(height: 12),
              if (isReadOnly)
                TextFormField(
                  controller: TextEditingController(
                    text: status == 'unactive'
                        ? 'Tidak Aktif'
                        : status == 'active'
                            ? 'Aktif'
                            : 'Unknown',
                  ),
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: 'Status',
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: status,
                  onChanged: (String? newValue) {
                    setState(() {
                      status = newValue;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'unactive',
                      child: Text('Tidak Aktif'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Aktif'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: 'Status Akun',
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
              const SizedBox(height: 20),
              const Text(
                'Riwayat Diabetes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Display the diabetes history
              if (diabetesHistory.isEmpty)
                const Center(
                  child: Text(
                    'Tidak ada data medical record.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                )
              else
                ...diabetesHistory.map((record) {
                  final date = DateTime.parse(record['created_at']);
                  final formattedDate =
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year}";

                  // Prediction logic
                  String predictionStatus = (record['prediction'] == 1)
                      ? 'Kemungkinan Terkena Diabetes'
                      : 'Tidak Terkena Diabetes';

                  return Card(
                    color: record['prediction'] == 1
                        ? const Color(0xFFFFE3E3)
                        : const Color(0xFFD1FADF),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${record['record_id']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                            predictionStatus,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Text(formattedDate),
                            ],
                          ),
                          
                          Text(
                              'Gula Darah: ${record['blood_glucose_level'] ?? 'N/A'} mg/dL'),
                          const SizedBox(height: 10),
                          
                        ],
                      ),
                    ),
                  );
                }),
            ],
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
      ),
    );
  }
}
