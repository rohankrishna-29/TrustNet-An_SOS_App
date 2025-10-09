/*
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
*/

/*
import 'package:flutter/material.dart';
import '../widgets/contact_tiles.dart';
import '../widgets/send_request_button.dart';
import '../services/trusted_contacts_services.dart';

class ContactsPage extends StatelessWidget {
  final String currentUid;
  final ConnectionsService service = ConnectionsService();

  ContactsPage({required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // dark background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // -----------------------------
                  // Pending Requests Section
                  // -----------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Pending Requests',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: service.getPendingRequests(currentUid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final requests = snapshot.data!;
                      if (requests.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('No pending requests', style: TextStyle(color: Colors.white54)),
                        );
                      }
                      return Column(
                        children: requests.map((request) {
                          return RequestTile(
                            name: request['name'] ?? request['email'],
                            userId: request['userId'],
                            currentUid: currentUid,
                            service: service,
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // -----------------------------
                  // Accepted Connections Section
                  // -----------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Connections',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: service.getAcceptedConnections(currentUid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final connections = snapshot.data!;
                      if (connections.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('No connections yet', style: TextStyle(color: Colors.white54)),
                        );
                      }
                      return Column(
                        children: connections.map((contact) {
                          return ConnectionsTile(
                            name: contact['name'] ?? contact['email'],
                            status: contact['alertStatus'] ?? 'green',
                            onMapPressed: () {
                              // TODO: handle map icon pressed
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // -----------------------------
            // Send Request Button
            // -----------------------------
            SendRequestButton(
              currentUid: currentUid,
              service: service,
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import '../widgets/contact_tiles.dart';
import '../widgets/send_request_button.dart';
import '../services/trusted_contacts_services.dart';

class ContactsPage extends StatelessWidget {
  final String currentUid;
  final ConnectionsService service = ConnectionsService();

  ContactsPage({required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -----------------------------
                    // Pending Requests Section
                    // -----------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Pending Requests',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: service.getPendingRequests(currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          debugPrint('Pending stream error: ${snapshot.error}');
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Error loading requests:\n${snapshot.error}',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final requests = snapshot.data ?? [];
                        if (requests.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No pending requests', style: TextStyle(color: Colors.white54)),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            return RequestTile(
                              name: request['name'] ?? request['email'] ?? 'Unknown User',
                              userId: request['userId'],
                              currentUid: currentUid,
                              service: service,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // -----------------------------
                    // Accepted Connections Section
                    // -----------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Connections',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: service.getAcceptedConnections(currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          debugPrint('Accepted stream error: ${snapshot.error}');
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Error loading connections:\n${snapshot.error}',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final connections = snapshot.data ?? [];
                        if (connections.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No connections yet', style: TextStyle(color: Colors.white54)),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: connections.length,
                          itemBuilder: (context, index) {
                            final contact = connections[index];
                            return ConnectionsTile(
                              name: contact['name'] ?? contact['email'] ?? 'Unknown Contact',
                              status: contact['alertStatus'] ?? 'green',
                              onMapPressed: () {},
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // -----------------------------
            // Send Request Button
            // -----------------------------
            SendRequestButton(
              currentUid: currentUid,
              service: service,
            ),
          ],
        ),
      ),
    );
  }
}
