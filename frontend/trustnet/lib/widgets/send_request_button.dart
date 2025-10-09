import 'package:flutter/material.dart';
import '../services/trusted_contacts_services.dart';

class SendRequestButton extends StatelessWidget {
  final String currentUid;
  final ConnectionsService service;

  const SendRequestButton({
    required this.currentUid,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show dialog to enter email
          final emailController = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Send Connection Request'),
              content: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter user email',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      try {
                        await service.sendConnectionRequest(currentUid, email);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Request sent to $email')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.person_add, size: 24),
        label: Text(
          'Send Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          backgroundColor: Color(0xFF784DD4),
        ),
      ),
    );
  }
}
