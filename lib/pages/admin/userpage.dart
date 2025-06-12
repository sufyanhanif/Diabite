import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:train_flutter/pages/admin/adminpage.dart';
import 'package:train_flutter/pages/admin/detailprofilpage.dart';
import 'package:train_flutter/supabase_service/admin_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

final adminService = AdminService();

class _UserPageState extends State<UserPage> {
  bool isLoading = true; // Loading state flag
  List<Map<String, dynamic>> userRecords = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final users = await adminService.getAllUsers();
      if (users != null) {
        setState(() {
          userRecords = users;
          // Filter users by role (only "user" role)
          filteredUsers =
              users.where((user) => user['role'] == 'user').toList();
          isLoading = false; // Set loading to false after data is fetched
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Set loading to false even if there's an error
      });
      // Handle error here (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
        ),
        backgroundColor: const Color(0xFFF2F9FC),
        title: const Text('Management User'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity, // Ensures the container takes full width
          height: double.infinity, // Ensures the container takes full height
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xffF2F9FC), Color(0xffAEBFF8)],
            ),
          ),
          child: Stack(
            children: [
              // Main content inside SingleChildScrollView for scrolling
              if (!isLoading)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      filteredUsers.isEmpty
                          ? const Center(child: Text("No users found"))
                          : ListView.builder(
                              shrinkWrap:
                                  true, // Ensures ListView doesn't take up extra space
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable ListView's own scroll
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to the DetailProfilPage with the user's ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailProfilPage(
                                            userId: user['id']),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.all(10),
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                user['name'] ?? 'No Name',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: user['status'] ==
                                                          'active'
                                                      ? const Color(0xFFD1FADF)
                                                      : const Color(
                                                          0xFFFFE3E3), // Green for Active, Red for Inactive
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                    user['status'] == 'active' ? 'Aktif' : 'Tidak Aktif',
                                                  style: const TextStyle(
                                                    color: Colors
                                                        .black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(8),
                                          Text('Emai: ${user['email'] ?? 'N/A'}'),
                                          const Gap(8),
                                         
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),

              // Loading Spinner
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
        ),
      ),
    );
  }
}
