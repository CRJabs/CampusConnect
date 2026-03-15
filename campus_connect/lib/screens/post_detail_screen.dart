import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String desc;
  // --- UPGRADED: Now accepts a List of strings instead of a single String ---
  final List<String> imageUrls;
  final String orgName;
  final String timeText;

  const PostDetailScreen(
      {super.key,
      required this.title,
      required this.desc,
      required this.imageUrls,
      required this.orgName,
      required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002147),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Back to Dashboard',
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
                        fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 15),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 25),
                // --- UPGRADED: Loops through all images and stacks them vertically ---
                if (imageUrls.isNotEmpty) ...[
                  ...imageUrls.map((url) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(url,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                errorBuilder: (c, e, s) => const SizedBox())),
                      )),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
