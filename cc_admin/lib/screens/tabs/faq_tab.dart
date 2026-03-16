import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/admin_dialogs.dart';

class FaqTab extends StatefulWidget {
  const FaqTab({super.key});

  @override
  State<FaqTab> createState() => _FaqTabState();
}

class _FaqTabState extends State<FaqTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isShowingAnsweredFaqs = false;
  late Stream<QuerySnapshot> _faqStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    _faqStream = FirebaseFirestore.instance
        .collection('faqs')
        .where('is_answered', isEqualTo: _isShowingAnsweredFaqs)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assistance Center',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () =>
                    AdminDialogs.showAnswerFaqDialog(context, null, null),
                icon: const Icon(Icons.add_comment),
                label: const Text('Add FAQ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() {
                      _isShowingAnsweredFaqs = false;
                      _updateStream();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: !_isShowingAnsweredFaqs
                                      ? const Color(0xFF002147)
                                      : Colors.transparent,
                                  width: 3))),
                      child: Center(
                          child: Text('Pending Questions',
                              style: TextStyle(
                                  fontWeight: !_isShowingAnsweredFaqs
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: !_isShowingAnsweredFaqs
                                      ? const Color(0xFF002147)
                                      : Colors.grey))),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() {
                      _isShowingAnsweredFaqs = true;
                      _updateStream();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: _isShowingAnsweredFaqs
                                      ? const Color(0xFF002147)
                                      : Colors.transparent,
                                  width: 3))),
                      child: Center(
                          child: Text('Answered FAQs',
                              style: TextStyle(
                                  fontWeight: _isShowingAnsweredFaqs
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _isShowingAnsweredFaqs
                                      ? const Color(0xFF002147)
                                      : Colors.grey))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _faqStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Firebase Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(_isShowingAnsweredFaqs
                          ? 'No answered FAQs available.'
                          : 'No pending questions waiting. You\'re all caught up!'));
                }

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    String q = data['question'] ?? 'No Question';
                    String a = data['answer'] ?? '';
                    String timeText = 'Unknown time';
                    if (data['timestamp'] != null) {
                      DateTime dt = (data['timestamp'] as Timestamp).toDate();
                      timeText = "${dt.month}/${dt.day}/${dt.year}";
                    }

                    return Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        leading: CircleAvatar(
                            backgroundColor: _isShowingAnsweredFaqs
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                                _isShowingAnsweredFaqs
                                    ? Icons.check
                                    : Icons.question_mark,
                                color: Colors.white)),
                        title: Text(q,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            if (_isShowingAnsweredFaqs) ...[
                              Text(a,
                                  style: TextStyle(color: Colors.grey.shade700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5)
                            ],
                            Text('Submitted: $timeText',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isShowingAnsweredFaqs)
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF002147),
                                      foregroundColor: Colors.white),
                                  onPressed: () =>
                                      AdminDialogs.showAnswerFaqDialog(
                                          context, doc.id, data),
                                  icon: const Icon(Icons.reply, size: 18),
                                  label: const Text('Provide Answer'))
                            else
                              TextButton.icon(
                                  onPressed: () =>
                                      AdminDialogs.showAnswerFaqDialog(
                                          context, doc.id, data),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit Answer')),
                            const SizedBox(width: 10),
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => AdminDialogs.confirmDelete(
                                        context, "FAQ: $q", () {
                                      FirebaseFirestore.instance
                                          .collection('faqs')
                                          .doc(doc.id)
                                          .delete();
                                    }),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
