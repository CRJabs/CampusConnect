import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/admin_dialogs.dart';

class DirectoryTab extends StatefulWidget {
  const DirectoryTab({super.key});

  @override
  State<DirectoryTab> createState() => _DirectoryTabState();
}

class _DirectoryTabState extends State<DirectoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _activeDirectoryTab = 'administrations';
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  late Stream<QuerySnapshot> _directoryStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    _directoryStream = FirebaseFirestore.instance
        .collection(_activeDirectoryTab)
        .orderBy('name')
        .snapshots();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildDirectoryTabButton(String title, String targetCollection) {
    bool isActive = _activeDirectoryTab == targetCollection;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _activeDirectoryTab = targetCollection;
          _searchCtrl.clear();
          _updateStream(); // Only fetch new data when changing tabs!
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: isActive
                          ? const Color(0xFF002147)
                          : Colors.transparent,
                      width: 3))),
          child: Center(
              child: Text(title,
                  style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color:
                          isActive ? const Color(0xFF002147) : Colors.grey))),
        ),
      ),
    );
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
              const Text('Campus Directory Master List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () => AdminDialogs.showAddEntityDialog(
                    context, _activeDirectoryTab),
                icon: const Icon(Icons.add_business),
                label: Text(
                    'Add New ${_activeDirectoryTab == 'departments' ? 'Department' : _activeDirectoryTab == 'organizations' ? 'Organization' : 'Administration'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
                _buildDirectoryTabButton('Administration', 'administrations'),
                _buildDirectoryTabButton('Academic Departments', 'departments'),
                _buildDirectoryTabButton(
                    'Student Organizations', 'organizations'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search directory by name or acronym...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            onChanged: (val) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                setState(() {});
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _directoryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No $_activeDirectoryTab found.'));
                  }

                  var docs = snapshot.data!.docs;
                  if (_searchCtrl.text.isNotEmpty) {
                    String query = _searchCtrl.text.toLowerCase();
                    docs = docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String name = (data['name'] ?? '').toLowerCase();
                      String acronym = (data['logo_text'] ?? '').toLowerCase();
                      return name.contains(query) || acronym.contains(query);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('No entries match your search.',
                            style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      String? profileUrl = data['profile_image_url'];
                      String logoText = data['logo_text'] ?? 'UB';

                      return Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            clipBehavior: Clip.antiAlias,
                            child: (profileUrl != null &&
                                    profileUrl.trim().isNotEmpty)
                                ? Image.network(profileUrl,
                                    fit: BoxFit.cover,
                                    cacheWidth: 90,
                                    cacheHeight: 90,
                                    errorBuilder: (c, e, s) => Center(
                                        child: Text(
                                            logoText.length > 4
                                                ? logoText.substring(0, 4)
                                                : logoText,
                                            style: const TextStyle(
                                                color: Color(0xFF002147),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))))
                                : Center(
                                    child:
                                        Text(logoText.length > 4 ? logoText.substring(0, 4) : logoText,
                                            style: const TextStyle(
                                                color: Color(0xFF002147),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))),
                          ),
                          title: Text(data['name'] ?? 'Unnamed',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("ID: ${doc.id}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                  onPressed: () =>
                                      AdminDialogs.showEditEntityDialog(context,
                                          _activeDirectoryTab, doc.id, data),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit Name')),
                              const SizedBox(width: 10),
                              TextButton.icon(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  onPressed: () => AdminDialogs.confirmDelete(
                                          context, "Entity: ${data['name']}",
                                          () async {
                                        await FirebaseFirestore.instance
                                            .collection(_activeDirectoryTab)
                                            .doc(doc.id)
                                            .delete();
                                        var notices = await FirebaseFirestore
                                            .instance
                                            .collection('organization_notices')
                                            .where('org_id', isEqualTo: doc.id)
                                            .get();
                                        if (notices.docs.isNotEmpty) {
                                          var batch = FirebaseFirestore.instance
                                              .batch();
                                          for (var noticeDoc in notices.docs) {
                                            batch.delete(noticeDoc.reference);
                                          }
                                          await batch.commit();
                                        }
                                      }),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
          )
        ],
      ),
    );
  }
}
