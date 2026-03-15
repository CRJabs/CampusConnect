import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String _searchQuery = '';
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  void _submitNewQuestionDialog() {
    final questionCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Submit a Question',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Your question will be sent to the administration. Once answered, it will appear publicly on this FAQ board.',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: questionCtrl,
                      decoration: const InputDecoration(
                          labelText: 'What would you like to ask?',
                          border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (questionCtrl.text.trim().isEmpty) return;
                          setDialogState(() => isSubmitting = true);

                          try {
                            // Send to database as an unanswered (blank) question
                            await FirebaseFirestore.instance
                                .collection('faqs')
                                .add({
                              'question': questionCtrl.text.trim(),
                              'answer': '',
                              'is_answered': false,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Question submitted successfully!'),
                                    backgroundColor: Colors.green));
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red));
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Submit Question'),
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
      child: Column(
        children: [
          // --- UPGRADED: Replaced Text with Image Placeholder ---
          Image.asset(
            'assets/faq.png',
            height: 100,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 100,
              width: 400,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300)),
              alignment: Alignment.center,
              child: const Text('Add FAQ Banner Image Here',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 15),
          const Text('Find answers to your most common questions here!',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),

          // --- LIVE SEARCH FIELD ---
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 0; // Reset to page 1 on new search
                });
              },
              decoration: const InputDecoration(
                  icon: Icon(Icons.search,
                      color: Color.fromARGB(255, 201, 201, 201)),
                  hintText: 'Type your question here...',
                  border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 40),

          // --- LIVE FIREBASE FAQ FEED ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('faqs')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF002147)));
              }

              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              // Filter out questions that haven't been answered by admin yet
              var allDocs = snapshot.data?.docs ?? [];
              var answeredDocs =
                  allDocs.where((doc) => doc['is_answered'] == true).toList();

              // Apply the live search filter
              var searchResults = answeredDocs.where((doc) {
                String q = (doc['question'] ?? '').toString().toLowerCase();
                return q.contains(_searchQuery.toLowerCase());
              }).toList();

              // --- EMPTY SEARCH STATE UI ---
              if (searchResults.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text("Can't find an answer to your question?",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text(
                          "Send them here and our administration will respond.",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002147),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20)),
                        onPressed: _submitNewQuestionDialog,
                        icon: const Icon(Icons.send),
                        label: const Text('Submit a Question',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              }

              // --- PAGINATION MATH ---
              int totalPages = (searchResults.length / _itemsPerPage).ceil();
              if (_currentPage >= totalPages && totalPages > 0)
                _currentPage = totalPages - 1;

              int startIndex = _currentPage * _itemsPerPage;
              int endIndex = startIndex + _itemsPerPage;
              if (endIndex > searchResults.length)
                endIndex = searchResults.length;

              var pagedResults = searchResults.sublist(startIndex, endIndex);

              return Column(
                children: [
                  // List of 10 FAQs
                  ...pagedResults.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildFaqTile(
                        data['question'] ?? '', data['answer'] ?? '');
                  }),

                  // Next/Prev Arrows
                  if (totalPages > 1) ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: _currentPage > 0
                              ? const Color(0xFF002147)
                              : Colors.grey,
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text('Page ${_currentPage + 1} of $totalPages',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          color: _currentPage < totalPages - 1
                              ? const Color(0xFF002147)
                              : Colors.grey,
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    )
                  ]
                ],
              );
            },
          ),
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
