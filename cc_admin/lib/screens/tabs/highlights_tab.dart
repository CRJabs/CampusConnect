import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/admin_dialogs.dart';
import '../../widgets/edit_highlight_dialog.dart';

class HighlightsTab extends StatefulWidget {
  const HighlightsTab({super.key});

  @override
  State<HighlightsTab> createState() => _HighlightsTabState();
}

class _HighlightsTabState extends State<HighlightsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Stream<QuerySnapshot> _highlightsStream;
  late Stream<QuerySnapshot> _slotsStream;

  @override
  void initState() {
    super.initState();
    _highlightsStream = FirebaseFirestore.instance
        .collection('highlights')
        .orderBy('timestamp', descending: true)
        .snapshots();
    _slotsStream =
        FirebaseFirestore.instance.collection('featured_sources').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Carousel Highlights',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const EditHighlightDialog()),
                icon: const Icon(Icons.add_to_photos),
                label: const Text('Add New Highlight',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _highlightsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        'No highlights found. They will fallback to default if empty.'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;

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
                          horizontal: 20, vertical: 10),
                      leading: Container(
                        width: 80,
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4)),
                        clipBehavior: Clip.antiAlias,
                        child: data['carousel_image_url'] != null
                            ? Image.network(data['carousel_image_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.image))
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                      title: Text(data['carousel_title'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['carousel_desc'] ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                              onPressed: () => showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => EditHighlightDialog(
                                      docId: doc.id, data: data)),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Details')),
                          const SizedBox(width: 10),
                          TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              onPressed: () => AdminDialogs.confirmDelete(
                                      context,
                                      "Highlight: ${data['carousel_title']}",
                                      () {
                                    FirebaseFirestore.instance
                                        .collection('highlights')
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
          const SizedBox(height: 60),
          const Text('Featured Announcements',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
              stream: _slotsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                      height: 70,
                      child: Center(child: LinearProgressIndicator()));
                }

                Map<String, Map<String, dynamic>> slotsData = {};
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    slotsData[doc.id] = doc.data() as Map<String, dynamic>;
                  }
                }

                return Column(
                    children: List.generate(6, (index) {
                  String slotId = 'slot_${index + 1}';
                  var data = slotsData[slotId];
                  bool isConfigured = data != null;

                  String orgName = data?['org_name'] ?? 'Empty Slot';
                  String collection = data?['collection'] ?? 'None';
                  int badgeColorInt = data?['badge_color'] ?? 0xFF9E9E9E;

                  return Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Colors.grey.shade300,
                            width: isConfigured ? 1 : 1.5,
                            style: isConfigured
                                ? BorderStyle.solid
                                : BorderStyle.none)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                          backgroundColor: Color(badgeColorInt),
                          child: Text('${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      title: Text(orgName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isConfigured ? Colors.black : Colors.grey)),
                      subtitle: isConfigured
                          ? Text('Pulls from: $collection',
                              style: const TextStyle(color: Colors.grey))
                          : const Text(
                              'Click configure to assign an account to this dashboard slot.'),
                      trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F2F5),
                              foregroundColor: const Color(0xFF002147),
                              elevation: 0),
                          onPressed: () => AdminDialogs.showConfigureSlotDialog(
                              context, slotId, data),
                          icon: const Icon(Icons.settings, size: 18),
                          label: const Text('Configure Slot')),
                    ),
                  );
                }));
              }),
        ],
      ),
    );
  }
}
