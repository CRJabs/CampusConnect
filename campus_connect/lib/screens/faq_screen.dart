import 'package:flutter/material.dart';
import '../models/mock_data.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
      child: Column(
        children: [
          const Text('Assistance Center',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'Find answers to common questions about University of Bohol',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const TextField(
              decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Type your question here...',
                  border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 40),
          ...MockData.faqs.entries
              .map((entry) => _buildFaqTile(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: Text(question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(answer,
                    style:
                        TextStyle(color: Colors.grey.shade700, height: 1.5))),
          ),
        ],
      ),
    );
  }
}
