import 'dart:async';
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

  Timer? _debounce;
  late Stream<QuerySnapshot> _faqStream;

  @override
  void initState() {
    super.initState();
    _faqStream = FirebaseFirestore.instance
        .collection('faqs')
        .where('is_answered', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

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
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Question'),
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      // --- FIX: Dynamic Mobile Padding ---
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 20, vertical: 40),
      child: Column(
        children: [
          Image.asset(
            'assets/faq.png',
            height: isDesktop ? 100 : 80,
            errorBuilder: (context, error, stackTrace) => Container(
              height: isDesktop ? 100 : 80,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300)),
              alignment: Alignment.center,
              child: const Text('Add FAQ Banner Image Here',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 15),
          const Text('Find answers to your most common questions here!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
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
          StreamBuilder<QuerySnapshot>(
            stream: _faqStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF002147)));
              }
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              var answeredDocs = snapshot.data?.docs ?? [];
              var searchResults = answeredDocs.where((doc) {
                String q = (doc['question'] ?? '').toString().toLowerCase();
                return q.contains(_searchQuery.toLowerCase());
              }).toList();

              if (searchResults.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text("Can't find an answer to your question?",
                          style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      const Text(
                          "Send them here and our administration will respond.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002147),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15)),
                        onPressed: _submitNewQuestionDialog,
                        icon: const Icon(Icons.send),
                        label: const Text('Submit a Question',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              }

              int totalPages = (searchResults.length / _itemsPerPage).ceil();
              if (_currentPage >= totalPages && totalPages > 0) {
                _currentPage = totalPages - 1;
              }

              int startIndex = _currentPage * _itemsPerPage;
              int endIndex = startIndex + _itemsPerPage;
              if (endIndex > searchResults.length) {
                endIndex = searchResults.length;
              }
              var pagedResults = searchResults.sublist(startIndex, endIndex);

              return Column(
                children: [
                  ...pagedResults.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildFaqTile(data['question'] ?? '',
                        data['answer'] ?? '', isDesktop);
                  }),
                  if (totalPages > 1) ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18),
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
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
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

  Widget _buildFaqTile(String question, String answer, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: ExpansionTile(
        // --- FIX: Dynamic mobile font sizes ---
        title: Text(question,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: isDesktop ? 16 : 14)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(answer,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                        fontSize: isDesktop ? 14 : 13))),
          ),
        ],
      ),
    );
  }
}
