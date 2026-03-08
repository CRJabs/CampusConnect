import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String desc;
  final String? imageUrl;
  final String orgName;
  final String timeText;

  const PostDetailScreen(
      {super.key,
      required this.title,
      required this.desc,
      this.imageUrl,
      required this.orgName,
      required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Announcement Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Container(
            width: 1000,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFF002147),
                          borderRadius: BorderRadius.circular(30)),
                      child: Text(orgName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(timeText,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 30),
                Text(title,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                  // FIXED: Used a ConstrainedBox instead of the constraints property
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 600),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(imageUrl!,
                          fit: BoxFit.contain, width: double.infinity),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                Text(desc, style: const TextStyle(fontSize: 18, height: 1.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
