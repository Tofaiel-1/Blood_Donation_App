import 'package:flutter/material.dart';

class OrgAdminScreen extends StatelessWidget {
  const OrgAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Admin')),
      body: Center(
        child: Text(
          'Organization Admin Dashboard - manage your organization and requests.',
        ),
      ),
    );
  }
}
