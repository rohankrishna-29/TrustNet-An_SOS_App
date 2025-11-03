import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  String name = '';
  String phone = '';
  String email = '';
  String sex = '';
  String dob = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔹 Load user data from Firestore
  Future<void> _loadProfile() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? 'Insert Name';
          phone = data['phone'] ?? 'xxxxxxxxxxxx';
          email = data['email'] ?? user!.email ?? 'xxxxxx@xxxx.xxx';
          sex = data['sex'] ?? 'Enter Sex';
          dob = data['dob'] ?? 'XX/XX/XXXX';
          isLoading = false;
        });
      } else {
        // No user doc yet
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  // 🔹 Save user data to Firestore
  Future<void> _saveProfile() async {
    if (user == null) return;

    try {
      await firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'sex': sex,
        'dob': dob,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved!')));
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        name = nameController.text;
        phone = phoneController.text;
        email = emailController.text;
        sex = sexController.text;
        dob = dobController.text;
        _saveProfile(); // Save to Firestore
      } else {
        nameController.text = name;
        phoneController.text = phone;
        emailController.text = email;
        sexController.text = sex;
        dobController.text = dob;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            isEditing
                ? TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Insert Name',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
            const SizedBox(height: 20),
            ProfileDetailRow(
              label: 'Mobile No.',
              value: isEditing ? phoneController : phone,
              isEditing: isEditing,
            ),
            ProfileDetailRow(
              label: 'Email-Id',
              value: isEditing ? emailController : email,
              isEditing: isEditing,
            ),
            ProfileDetailRow(
              label: 'Sex',
              value: isEditing ? sexController : sex,
              isEditing: isEditing,
            ),
            ProfileDetailRow(
              label: 'DOB',
              value: isEditing ? dobController : dob,
              isEditing: isEditing,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: toggleEditMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditing ? 'Save Details' : 'Edit Details',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isEditing;

  const ProfileDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          isEditing
              ? Expanded(
                  child: TextField(
                    controller: value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter $label',
                      hintStyle: const TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}
