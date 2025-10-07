import 'package:flutter/material.dart';

class TrustedContactsPage extends StatefulWidget {
  const TrustedContactsPage({super.key});

  @override
  _TrustedContactsPageState createState() => _TrustedContactsPageState();
}

class _TrustedContactsPageState extends State<TrustedContactsPage> {
  List<Map<String, String>> contacts = [
    {'name': 'John Doe', 'status': 'active'},
    {'name': 'Jane Smith', 'status': 'active'},
    {'name': 'Michael Lee', 'status': 'active'},
    {'name': 'Emily Clark', 'status': 'active'},
  ];

  List<Map<String, String>> requests = [
    {'name': 'Samuel Green', 'status': 'pending'},
    {'name': 'Lucy Brown', 'status': 'pending'},
  ];

  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 2)); // simulate delay
    if (!mounted) return; // ✅ prevent setState() after dispose
    setState(() {
      contacts = contacts = List.from(contacts);
      requests = List.from(requests);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRUSTED CONTACTS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...contacts.map((c) => ContactTile(name: c['name']!)),
                  SizedBox(height: 20),
                  Text(
                    'Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...requests.map((r) => RequestTile(
                        name: r['name']!,
                        status: r['status']!,
                      )),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '+ Connect with more',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String name;
  const ContactTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 10),
          Text(name, style: TextStyle(color: Colors.white)),
          Spacer(),
          Icon(Icons.location_on, color: Colors.white),
        ],
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final String name;
  final String status;
  const RequestTile({super.key, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 10),
          Text(name, style: TextStyle(color: Colors.white)),
          Spacer(),
          status == 'pending'
              ? Icon(Icons.close, color: Colors.red)
              : Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }
}
