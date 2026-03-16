import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/admin_dialogs.dart';

class AccountsTab extends StatefulWidget {
  const AccountsTab({super.key});

  @override
  State<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  // --- OPTIMIZATION: Persistent Stream ---
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    // Start the stream ONCE when the tab opens
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
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
              const Text('Accounts Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () => AdminDialogs.showAddAccountDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Register New Account',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search accounts by email or role...',
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
              // --- OPTIMIZATION: Debouncer prevents UI freezing while typing ---
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                setState(() {});
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream, // Uses the persistent stream!
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text('No accounts found.'));

                var docs = snapshot.data!.docs;
                if (_searchCtrl.text.isNotEmpty) {
                  String query = _searchCtrl.text.toLowerCase();
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String email = (data['email'] ?? '').toLowerCase();
                    String role = (data['role'] ?? '').toLowerCase();
                    return email.contains(query) || role.contains(query);
                  }).toList();
                }

                if (docs.isEmpty)
                  return const Center(
                      child: Text('No accounts match your search.',
                          style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
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
                        leading: CircleAvatar(
                            backgroundColor: const Color(0xFF002147),
                            child: Icon(
                                data['role'] == 'admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: Colors.white)),
                        title: Text(data['email'] ?? 'No Email',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "Role: ${data['role']?.toUpperCase() ?? 'NONE'} | Links to: ${data['target_collection'] ?? 'N/A'}",
                            style: TextStyle(color: Colors.grey.shade600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                                onPressed: () =>
                                    AdminDialogs.showLoginHistoryDialog(
                                        context, doc.id, data['email']),
                                icon: const Icon(Icons.history, size: 18),
                                label: const Text('Logs')),
                            const SizedBox(width: 10),
                            TextButton.icon(
                                onPressed: () =>
                                    AdminDialogs.showEditAccountDialog(
                                        context, doc.id, data),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit')),
                            const SizedBox(width: 10),
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => AdminDialogs.confirmDelete(
                                        context, "Account: ${data['email']}",
                                        () {
                                      FirebaseFirestore.instance
                                          .collection('users')
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
