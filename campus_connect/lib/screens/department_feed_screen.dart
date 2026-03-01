import 'package:flutter/material.dart';
import '../models/mock_data.dart';

class DepartmentFeedScreen extends StatelessWidget {
  final Department department;
  const DepartmentFeedScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Back to Dashboard', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildNoticeFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Color(0xFF002147),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: const Color(0xFF002147),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 4)),
                  transform: Matrix4.translationValues(0, -50, 0),
                  child: const Center(
                      child: Text('Co',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(department.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Training professionals committed to service.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNoticeFeed() {
    return Column(
      children: MockData.sampleNotices.map((notice) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                      backgroundColor: Color(0xFF002147),
                      radius: 16,
                      child: Text('Co',
                          style: TextStyle(color: Colors.white, fontSize: 10))),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(department.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(notice.timeAgo,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(notice.description,
                  style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 10),
              const Text('See More ∨',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
