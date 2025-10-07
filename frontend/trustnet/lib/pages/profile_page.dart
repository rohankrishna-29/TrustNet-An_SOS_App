import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Insert Name';
  String mobile = 'xxxxxxxxxxxx';
  String email = 'xxxxxx@xxxx.xxx';
  String sex = 'Enter Sex';
  String dob = 'XX/XX/XXXX';

  // Text controllers for editing profile details
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  bool isEditing = false;

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Save the entered data when switching off edit mode
        name = nameController.text;
        mobile = mobileController.text;
        email = emailController.text;
        sex = sexController.text;
        dob = dobController.text;
      } else {
        // Set the controllers to the current profile details
        nameController.text = name;
        mobileController.text = mobile;
        emailController.text = email;
        sexController.text = sex;
        dobController.text = dob;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            isEditing
                ? TextField(
                    controller: nameController,
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Insert Name',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
            SizedBox(height: 20),
            ProfileDetailRow(
              label: 'Mobile No.',
              value: isEditing ? mobileController : mobile,
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
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: toggleEditMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditing ? 'Save Details' : 'Edit Details',
                style: TextStyle(color: Colors.white),
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

  const ProfileDetailRow({super.key, 
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
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(width: 10),
          isEditing
              ? Expanded(
                  child: TextField(
                    controller: value,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter $label',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Expanded(
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}
