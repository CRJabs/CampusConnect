import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedDepartmentId;
  bool _isSubmitting = false;

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate() || _selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select a department.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Create the new notice document
      await firestore.collection('organization_notices').add({
        'department_id': _selectedDepartmentId,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Increment the notification badge count for that specific department
      await firestore
          .collection('departments')
          .doc(_selectedDepartmentId)
          .update({
        'new_notices_count': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Announcement Posted Successfully!',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green),
        );

        // Clear the form
        _titleController.clear();
        _descController.clear();
        setState(() => _selectedDepartmentId = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context); // Returns to the previous screen (Dashboard)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002147), // UB Navy
        foregroundColor: Colors.white,
        title: const Text('CampusConnect Admin Portal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Post New Announcement',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                      'Publish a notice to a specific department. This will instantly update the public kiosks.',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),

                  // Dynamic Dropdown populated from Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('departments')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      final departments = snapshot.data!.docs;

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Target Department',
                            border: OutlineInputBorder()),
                        value: _selectedDepartmentId,
                        items: departments.map((doc) {
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(doc['name']),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedDepartmentId = value),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        labelText: 'Announcement Title',
                        border: OutlineInputBorder()),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                        labelText: 'Description / Full Details',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true),
                    maxLines: 5,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter the details' : null,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107), // UB Gold
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _isSubmitting ? null : _submitAnnouncement,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2))
                          : const Text('Publish Announcement',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
