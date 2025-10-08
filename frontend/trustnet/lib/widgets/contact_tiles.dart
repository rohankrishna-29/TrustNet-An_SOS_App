import 'package:flutter/material.dart';
import '../services/trusted_contacts_services.dart';

/// ----------------------------
/// CONNECTIONS TILE
/// ----------------------------
class ConnectionsTile extends StatelessWidget {
  final String name;
  final String status; // 'green', 'red', 'yellow'
  final VoidCallback? onMapPressed;

  ConnectionsTile({
    required this.name,
    required this.status,
    this.onMapPressed,
  });

  Color _getBorderColor() {
    switch (status) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _getBorderColor(), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: onMapPressed,
          ),
        ],
      ),
    );
  }
}

/// ----------------------------
/// REQUEST TILE
/// ----------------------------
class RequestTile extends StatelessWidget {
  final String name;
  final String userId;
  final String currentUid;
  final ConnectionsService service;

  RequestTile({
    required this.name,
    required this.userId,
    required this.currentUid,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              await service.acceptConnectionRequest(currentUid, userId);
            },
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              await service.rejectConnectionRequest(currentUid, userId);
            },
          ),
        ],
      ),
    );
  }
}
