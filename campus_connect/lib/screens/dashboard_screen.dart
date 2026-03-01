import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mock_data.dart'; // Still needed for the Department model and static announcements
import 'department_feed_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 40),
          const Text('Latest Announcements',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildInfoCard(
                      'Enrollment',
                      'Enrollment for S.Y. 2026-2027',
                      'Online enrollment is now open. Secure your slot early!',
                      Colors.red)),
              const SizedBox(width: 20),
              Expanded(
                  child: _buildInfoCard(
                      'Event',
                      'UB Foundation Week',
                      'Join us for a week of activities celebrating 80 years of excellence.',
                      Colors.orange)),
              const SizedBox(width: 20),
              Expanded(
                  child: _buildInfoCard(
                      'Announcement',
                      'New Library Hours',
                      'The library will now be open from 7AM to 9PM on weekdays.',
                      const Color(0xFF002147))),
            ],
          ),
          const SizedBox(height: 40),
          const Text('Explore',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildDepartmentList(context),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF002147),
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=1200&auto=format&fit=crop'), // Used a reliable placeholder
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Graduation Ceremony 2026',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'Congratulations to the Class of 2026! Join us on March 28.',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: () {},
            child: const Text('View Details →',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String badgeText, String title, String desc, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: badgeColor, borderRadius: BorderRadius.circular(20)),
            child: Text(badgeText,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 15),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 15),
          const Text('Read More →',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  // --- THE NEW FIREBASE INTEGRATION ---
  Widget _buildDepartmentList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
            child: const Row(
              children: [
                Expanded(
                    child: Center(
                        child: Text('Departments',
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(
                    child: Center(
                        child: Text('Organizations',
                            style: TextStyle(color: Colors.grey)))),
              ],
            ),
          ),

          // StreamBuilder listens to Firestore in real-time
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('departments')
                .orderBy('name')
                .snapshots(),
            builder: (context, snapshot) {
              // 1. Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF002147))),
                );
              }

              // 2. Error State
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                      child:
                          Text('Error loading departments: ${snapshot.error}')),
                );
              }

              // 3. Empty State (No documents in Firestore yet)
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      'No departments found.\nPlease add documents to the "departments" collection in Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // 4. Data Loaded Successfully
              final departments = snapshot.data!.docs;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: departments.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade200, height: 1),
                itemBuilder: (context, index) {
                  // Extract data from the current Firestore document
                  var doc = departments[index];
                  var deptData = doc.data() as Map<String, dynamic>;

                  // Safely parse the fields, providing fallbacks if missing
                  String name = deptData['name'] ?? 'Unknown Department';
                  String logoText = deptData['logo_text'] ?? 'UB';
                  int newNotices = deptData['new_notices_count'] ?? 0;

                  // Convert the Firebase data into your existing Department model
                  Department deptModel = Department(doc.id, name, newNotices);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF002147),
                      child: Text(logoText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (newNotices > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text('$newNotices new',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        const SizedBox(width: 10),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      // Navigate to Feed, passing the newly created model
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DepartmentFeedScreen(department: deptModel),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
