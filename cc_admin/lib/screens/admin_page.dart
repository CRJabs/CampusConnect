import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'login_screen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // --- NEW STATE VARS ---
  String _activeDirectoryTab = 'administrations';
  bool _isShowingAnsweredFaqs = false; // False = Pending/Blank, True = Answered

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFF002147),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const SizedBox(width: 20),
              Image.network(
                'https://raw.githubusercontent.com/username/repo/branch/CampusConnect_White_Logo.png',
                height: 40,
                errorBuilder: (context, error, stackTrace) => const Text(
                    'CampusConnect Admin',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: [
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.admin_panel_settings,
                      size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Super Admin',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))
                ]),
              ),
            ),
            Center(
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(0xFF002147),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                        child: Row(children: [
                      Icon(Icons.people_alt, size: 16),
                      SizedBox(width: 8),
                      Text('Accounts',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold))
                    ])),
                    Tab(
                        child: Row(children: [
                      Icon(Icons.account_balance, size: 16),
                      SizedBox(width: 8),
                      Text('Directory',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold))
                    ])),
                    Tab(
                        child: Row(children: [
                      Icon(Icons.star, size: 16),
                      SizedBox(width: 8),
                      Text('Highlights',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold))
                    ])),
                    // --- UPGRADED: Settings changed to FAQ ---
                    Tab(
                        child: Row(children: [
                      Icon(Icons.help_outline, size: 16),
                      SizedBox(width: 8),
                      Text('FAQ',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold))
                    ])),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 30),
            TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20)),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 20),
          ],
        ),
        body: Center(
          child: Container(
            width: 1600,
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ]),
            child: TabBarView(
              children: [
                _buildAccountsTab(),
                _buildDirectoryTab(),
                _buildHighlightsTab(),
                _buildFaqTab(), // --- UPGRADED: Connects to new FAQ manager ---
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: ACCOUNTS MANAGEMENT
  // ==========================================
  Widget _buildAccountsTab() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Accounts Control Panel',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () => _showAddAccountDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Register New Account',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text('No accounts found.'));

                return ListView.builder(
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
                                onPressed: () => _showLoginHistoryDialog(
                                    context, doc.id, data['email']),
                                icon: const Icon(Icons.history, size: 18),
                                label: const Text('Logs')),
                            const SizedBox(width: 10),
                            TextButton.icon(
                                onPressed: () => _showEditAccountDialog(
                                    context, doc.id, data),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit')),
                            const SizedBox(width: 10),
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => _deleteAccount(doc.id),
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

  void _showAddAccountDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'organization';
    String? selectedTargetId;
    bool isSaving = false;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Register Account'),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext))
                  ]),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      TextField(
                          controller: passCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Secure Password',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                            labelText: 'Account Role',
                            border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: 'admin',
                              child: Text('Super Admin (Full Access)')),
                          DropdownMenuItem(
                              value: 'administration',
                              child: Text('Administration Editor')),
                          DropdownMenuItem(
                              value: 'department',
                              child: Text('Department Editor')),
                          DropdownMenuItem(
                              value: 'organization',
                              child: Text('Organization Editor')),
                        ],
                        onChanged: (val) => setDialogState(() {
                          selectedRole = val!;
                          selectedTargetId = null;
                        }),
                      ),
                      const SizedBox(height: 15),
                      if (selectedRole != 'admin')
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(selectedRole == 'department'
                                  ? 'departments'
                                  : selectedRole == 'organization'
                                      ? 'organizations'
                                      : 'administrations')
                              .orderBy('name')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const LinearProgressIndicator();
                            return DropdownButtonFormField<String>(
                              value: selectedTargetId,
                              decoration: InputDecoration(
                                  labelText:
                                      'Link to specific ${selectedRole.toUpperCase()}',
                                  border: const OutlineInputBorder()),
                              items: snapshot.data!.docs
                                  .map((doc) => DropdownMenuItem(
                                      value: doc.id, child: Text(doc['name'])))
                                  .toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedTargetId = val),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50)),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty)
                            return;
                          if (selectedRole != 'admin' &&
                              selectedTargetId == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please select an entity to link to.')));
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            FirebaseApp tempApp = await Firebase.initializeApp(
                                name: 'tempAuthCreation',
                                options: Firebase.app().options);
                            UserCredential newCred =
                                await FirebaseAuth.instanceFor(app: tempApp)
                                    .createUserWithEmailAndPassword(
                                        email: emailCtrl.text.trim(),
                                        password: passCtrl.text.trim());
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(newCred.user!.uid)
                                .set({
                              'email': emailCtrl.text.trim(),
                              'role': selectedRole,
                              if (selectedTargetId != null)
                                'target_id': selectedTargetId,
                              if (selectedTargetId != null)
                                'target_collection':
                                    selectedRole == 'department'
                                        ? 'departments'
                                        : selectedRole == 'organization'
                                            ? 'organizations'
                                            : 'administrations',
                            });
                            await tempApp.delete();
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Account Created Successfully!'),
                                    backgroundColor: Colors.green));
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red));
                            setDialogState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account'),
                )
              ],
            );
          });
        });
  }

  void _showEditAccountDialog(
      BuildContext context, String uid, Map<String, dynamic> currentData) {
    final emailCtrl = TextEditingController(text: currentData['email']);
    final passCtrl = TextEditingController();
    bool isSaving = false;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Account Data'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Note: Changing email/password here updates the database record. Full Authentication syncing requires Firebase Functions/Admin SDK.',
                        style: TextStyle(color: Colors.orange, fontSize: 12)),
                    const SizedBox(height: 15),
                    TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 15),
                    TextField(
                        controller: passCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'New Password (Leave blank to keep current)',
                            border: OutlineInputBorder())),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({
                            'email': emailCtrl.text.trim(),
                          });
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Database record updated.'),
                                  backgroundColor: Colors.green));
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes'),
                )
              ],
            );
          });
        });
  }

  void _deleteAccount(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account profile deleted from database.'),
        backgroundColor: Colors.red));
  }

  void _showLoginHistoryDialog(
      BuildContext context, String uid, String? email) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 700,
                height: 600,
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Access Logs: $email',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close))
                        ]),
                    const Divider(),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('login_history')
                              .orderBy('timestamp', descending: true)
                              .limit(50)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return const Center(
                                  child: CircularProgressIndicator());
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty)
                              return const Center(
                                  child: Text('No login history found.',
                                      style: TextStyle(color: Colors.grey)));
                            return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var log = snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                                  String timeStr = 'Unknown Time';
                                  if (log['timestamp'] != null) {
                                    DateTime dt =
                                        (log['timestamp'] as Timestamp)
                                            .toDate();
                                    timeStr =
                                        "${dt.month}/${dt.day}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                                  }
                                  return ListTile(
                                    leading: const Icon(Icons.login,
                                        color: Colors.green),
                                    title: const Text("Successful Login",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        "Device: ${log['device'] ?? 'Unknown'}"),
                                    trailing: Text(timeStr,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  );
                                });
                          }),
                    )
                  ],
                ),
              ));
        });
  }

  // ==========================================
  // TAB 2: DIRECTORY MANAGEMENT
  // ==========================================
  Widget _buildDirectoryTab() {
    return StatefulBuilder(builder: (context, setTabState) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Campus Directory Master List',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20)),
                  onPressed: () =>
                      _showAddEntityDialog(context, _activeDirectoryTab),
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
                      bottom:
                          BorderSide(color: Colors.grey.shade300, width: 2))),
              child: Row(
                children: [
                  _buildDirectoryTabButton(
                      'Administration', 'administrations', setTabState),
                  _buildDirectoryTabButton(
                      'Academic Departments', 'departments', setTabState),
                  _buildDirectoryTabButton(
                      'Student Organizations', 'organizations', setTabState),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(_activeDirectoryTab)
                      .orderBy('name')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                      return Center(
                          child: Text('No $_activeDirectoryTab found.'));
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
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
                                  color: Color(0xFF002147),
                                  shape: BoxShape.circle),
                              clipBehavior: Clip.antiAlias,
                              child: (profileUrl != null &&
                                      profileUrl.trim().isNotEmpty)
                                  ? Image.network(profileUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Center(
                                          child:
                                              Text(logoText.length > 4 ? logoText.substring(0, 4) : logoText,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold))))
                                  : Center(
                                      child:
                                          Text(logoText.length > 4 ? logoText.substring(0, 4) : logoText,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold))),
                            ),
                            title: Text(data['name'] ?? 'Unnamed',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text("ID: ${doc.id}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                    onPressed: () => _showEditEntityDialog(
                                        context,
                                        _activeDirectoryTab,
                                        doc.id,
                                        data),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit Name')),
                                const SizedBox(width: 10),
                                TextButton.icon(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection(_activeDirectoryTab)
                                          .doc(doc.id)
                                          .delete();
                                    },
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
    });
  }

  Widget _buildDirectoryTabButton(
      String title, String targetCollection, StateSetter setTabState) {
    bool isActive = _activeDirectoryTab == targetCollection;
    return Expanded(
      child: InkWell(
        onTap: () => setTabState(() => _activeDirectoryTab = targetCollection),
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

  void _showAddEntityDialog(BuildContext context, String collection) {
    final nameCtrl = TextEditingController();
    final logoCtrl = TextEditingController();
    bool isSaving = false;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Add to $collection Directory'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Full Entity Name',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 15),
                    TextField(
                        controller: logoCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Fallback Initials (Max 4)',
                            border: OutlineInputBorder()),
                        maxLength: 4),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameCtrl.text.isEmpty) return;
                          setDialogState(() => isSaving = true);
                          await FirebaseFirestore.instance
                              .collection(collection)
                              .add({
                            'name': nameCtrl.text.trim(),
                            'logo_text': logoCtrl.text.trim().toUpperCase(),
                            'new_notices_count': 0,
                          });
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Create'),
                )
              ],
            );
          });
        });
  }

  void _showEditEntityDialog(BuildContext context, String collection,
      String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    bool isSaving = false;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Entity Name'),
              content: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', border: OutlineInputBorder())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameCtrl.text.isEmpty) return;
                          setDialogState(() => isSaving = true);
                          await FirebaseFirestore.instance
                              .collection(collection)
                              .doc(docId)
                              .update({'name': nameCtrl.text.trim()});
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save'),
                )
              ],
            );
          });
        });
  }

  // ==========================================
  // TAB 3: HIGHLIGHTS MANAGEMENT
  // ==========================================
  Widget _buildHighlightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Highlights (Carousel)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () => _showEditHighlightDialog(null, null),
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
            stream: FirebaseFirestore.instance
                .collection('highlights')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        'No highlights found. They will fallback to default if empty.'));

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
                              onPressed: () =>
                                  _showEditHighlightDialog(doc.id, data),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Details')),
                          const SizedBox(width: 10),
                          TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              onPressed: () => FirebaseFirestore.instance
                                  .collection('highlights')
                                  .doc(doc.id)
                                  .delete(),
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
          const Text('Featured Announcements (Dashboard Cards)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'Select exactly 6 accounts. The system will automatically display their single most recent post on the Dashboard.',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          ...List.generate(6, (index) {
            String slotId = 'slot_${index + 1}';
            return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('featured_sources')
                    .doc(slotId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const SizedBox(
                        height: 70,
                        child: Center(child: LinearProgressIndicator()));

                  bool isConfigured = snapshot.hasData && snapshot.data!.exists;
                  var data = isConfigured
                      ? snapshot.data!.data() as Map<String, dynamic>
                      : null;

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
                                fontWeight: FontWeight.bold)),
                      ),
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
                          onPressed: () =>
                              _showConfigureSlotDialog(slotId, data),
                          icon: const Icon(Icons.settings, size: 18),
                          label: const Text('Configure Slot')),
                    ),
                  );
                });
          }),
        ],
      ),
    );
  }

  void _showConfigureSlotDialog(
      String slotId, Map<String, dynamic>? currentData) {
    String selectedCollection = currentData?['collection'] ?? 'departments';
    String? selectedOrgId = currentData?['org_id'];
    String? selectedOrgName = currentData?['org_name'];
    int selectedColor = currentData?['badge_color'] ?? 0xFFF44336;

    final List<int> badgeColors = [
      0xFFF44336,
      0xFF2196F3,
      0xFF4CAF50,
      0xFFFF9800,
      0xFF9C27B0,
      0xFF009688,
    ];

    bool isSaving = false;

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Configure $slotId',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Select Account Type',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCollection,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: 'administrations',
                            child: Text('Administrations')),
                        DropdownMenuItem(
                            value: 'departments',
                            child: Text('Academic Departments')),
                        DropdownMenuItem(
                            value: 'organizations',
                            child: Text('Student Organizations')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedCollection = val!;
                          selectedOrgId = null;
                          selectedOrgName = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('2. Select Specific Account',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(selectedCollection)
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const LinearProgressIndicator();

                        bool idExists = snapshot.data!.docs
                            .any((doc) => doc.id == selectedOrgId);
                        if (!idExists) {
                          selectedOrgId = null;
                          selectedOrgName = null;
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedOrgId,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Choose account...'),
                          items: snapshot.data!.docs
                              .map((doc) => DropdownMenuItem(
                                  value: doc.id, child: Text(doc['name'])))
                              .toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedOrgId = val;
                              selectedOrgName = snapshot.data!.docs
                                  .firstWhere((doc) => doc.id == val)['name'];
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('3. Select Dashboard Badge Color',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: badgeColors.map((colorInt) {
                        bool isSelected = selectedColor == colorInt;
                        return InkWell(
                          onTap: () =>
                              setDialogState(() => selectedColor = colorInt),
                          child: CircleAvatar(
                            backgroundColor: Color(colorInt),
                            radius: 18,
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (selectedOrgId == null || selectedOrgName == null)
                            return;
                          setDialogState(() => isSaving = true);

                          await FirebaseFirestore.instance
                              .collection('featured_sources')
                              .doc(slotId)
                              .set({
                            'org_id': selectedOrgId,
                            'org_name': selectedOrgName,
                            'collection': selectedCollection,
                            'badge_color': selectedColor,
                          });

                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Slot'),
                )
              ],
            );
          });
        });
  }

  void _showEditHighlightDialog(String? docId, Map<String, dynamic>? data) {
    final carouselTitleCtrl =
        TextEditingController(text: data?['carousel_title']);
    final carouselDescCtrl =
        TextEditingController(text: data?['carousel_desc']);
    final postTitleCtrl = TextEditingController(text: data?['post_title']);
    final postDescCtrl = TextEditingController(text: data?['post_desc']);

    String? finalCarouselImageUrl = data?['carousel_image_url'];
    String? finalPostImageUrl = data?['post_image_url'];

    bool isSaving = false;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            bool isUploadingCarousel = false;
            bool isUploadingPost = false;

            Future<void> handleImageUpload(bool isCarousel) async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 85);
              if (image == null) return;

              setDialogState(() {
                if (isCarousel)
                  isUploadingCarousel = true;
                else
                  isUploadingPost = true;
              });

              try {
                String prefix = isCarousel ? 'carousel' : 'post';
                String storagePath =
                    'highlights/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                final storageRef =
                    FirebaseStorage.instance.ref().child(storagePath);

                if (kIsWeb) {
                  final imgData = await image.readAsBytes();
                  await storageRef.putData(
                      imgData, SettableMetadata(contentType: 'image/jpeg'));
                }

                String downloadUrl = await storageRef.getDownloadURL();

                setDialogState(() {
                  if (isCarousel)
                    finalCarouselImageUrl = downloadUrl;
                  else
                    finalPostImageUrl = downloadUrl;
                });
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Upload Error: $e')));
                }
              } finally {
                setDialogState(() {
                  if (isCarousel)
                    isUploadingCarousel = false;
                  else
                    isUploadingPost = false;
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        docId == null
                            ? 'Create New Highlight'
                            : 'Edit Highlight Details',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext))
                  ]),
              content: SizedBox(
                width: 700,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. Dashboard Carousel Display',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF002147))),
                      const SizedBox(height: 10),
                      const Text(
                          'This is what users see scrolling on the main dashboard.',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 15),
                      TextField(
                          controller: carouselTitleCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Carousel Main Heading',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      TextField(
                          controller: carouselDescCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Carousel Subheading',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)),
                          clipBehavior: Clip.antiAlias,
                          child: (finalCarouselImageUrl != null)
                              ? Image.network(finalCarouselImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                      child: Icon(Icons.broken_image)))
                              : const Center(
                                  child: Icon(Icons.image,
                                      color: Colors.grey, size: 40))),
                      const SizedBox(height: 10),
                      Center(
                          child: isUploadingCarousel
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF002147),
                                      foregroundColor: Colors.white),
                                  onPressed: () => handleImageUpload(true),
                                  icon: const Icon(Icons.add_photo_alternate,
                                      size: 18),
                                  label: const Text(
                                      'Upload Carousel Banner (16:9)'))),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 30),
                      const Text('2. Detailed Post View',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF002147))),
                      const SizedBox(height: 10),
                      const Text(
                          'This is what opens when a user clicks "View Details".',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 15),
                      TextField(
                          controller: postTitleCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Detailed Post Heading',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 15),
                      TextField(
                          controller: postDescCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Full Description',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true),
                          maxLines: 5),
                      const SizedBox(height: 15),
                      Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)),
                          clipBehavior: Clip.antiAlias,
                          child: (finalPostImageUrl != null)
                              ? Image.network(finalPostImageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Center(
                                      child: Icon(Icons.broken_image)))
                              : const Center(
                                  child: Icon(Icons.image,
                                      color: Colors.grey, size: 40))),
                      const SizedBox(height: 10),
                      Center(
                          child: isUploadingPost
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF002147),
                                      foregroundColor: Colors.white),
                                  onPressed: () => handleImageUpload(false),
                                  icon: const Icon(Icons.add_photo_alternate,
                                      size: 18),
                                  label: const Text(
                                      'Upload Detailed Image (Optional)'))),
                    ],
                  ),
                ),
              ),
              actions: [
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002147),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: isSaving ||
                                isUploadingCarousel ||
                                isUploadingPost
                            ? null
                            : () async {
                                if (carouselTitleCtrl.text.isEmpty ||
                                    carouselDescCtrl.text.isEmpty ||
                                    postTitleCtrl.text.isEmpty ||
                                    postDescCtrl.text.isEmpty ||
                                    finalCarouselImageUrl == null) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Please fill out all required text fields and ensure a Carousel Banner is uploaded.')));
                                  return;
                                }

                                setDialogState(() => isSaving = true);
                                try {
                                  Map<String, dynamic> payload = {
                                    'carousel_title':
                                        carouselTitleCtrl.text.trim(),
                                    'carousel_desc':
                                        carouselDescCtrl.text.trim(),
                                    'post_title': postTitleCtrl.text.trim(),
                                    'post_desc': postDescCtrl.text.trim(),
                                    'carousel_image_url': finalCarouselImageUrl,
                                    'post_image_url': finalPostImageUrl,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  };

                                  if (docId == null) {
                                    await FirebaseFirestore.instance
                                        .collection('highlights')
                                        .add(payload);
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('highlights')
                                        .doc(docId)
                                        .update(payload);
                                  }

                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext);
                                } catch (e) {
                                  if (dialogContext.mounted) {
                                    ScaffoldMessenger.of(dialogContext)
                                        .showSnackBar(SnackBar(
                                            content: Text('Save Error: $e')));
                                  }
                                  setDialogState(() => isSaving = false);
                                }
                              },
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Publish Highlight',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))))
              ],
            );
          });
        });
  }

  // ==========================================
  // TAB 4: FAQ MANAGEMENT (NEW)
  // ==========================================
  Widget _buildFaqTab() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assistance Center (FAQ) Manager',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002147),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20)),
                onPressed: () =>
                    _showAnswerFaqDialog(null, null), // Add manual FAQ
                icon: const Icon(Icons.add_comment),
                label: const Text('Add FAQ Manually',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Toggle between Blank (Pending) and Answered
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isShowingAnsweredFaqs = false),
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
                          child: Text('Pending Questions (Blank)',
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
                    onTap: () => setState(() => _isShowingAnsweredFaqs = true),
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
              stream: FirebaseFirestore.instance
                  .collection('faqs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text('No questions found.'));

                // Filter locally based on the toggle state to avoid needing complex Firestore indexes
                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  bool isAnswered = data['is_answered'] ?? false;
                  return isAnswered == _isShowingAnsweredFaqs;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                      child: Text(_isShowingAnsweredFaqs
                          ? 'No answered FAQs available.'
                          : 'No pending questions waiting. You\'re all caught up!'));
                }

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
                              const SizedBox(height: 5),
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
                                      _showAnswerFaqDialog(doc.id, data),
                                  icon: const Icon(Icons.reply, size: 18),
                                  label: const Text('Provide Answer'))
                            else
                              TextButton.icon(
                                  onPressed: () =>
                                      _showAnswerFaqDialog(doc.id, data),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit Answer')),
                            const SizedBox(width: 10),
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => FirebaseFirestore.instance
                                    .collection('faqs')
                                    .doc(doc.id)
                                    .delete(),
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

  void _showAnswerFaqDialog(String? docId, Map<String, dynamic>? data) {
    final questionCtrl = TextEditingController(text: data?['question']);
    final answerCtrl = TextEditingController(text: data?['answer']);
    bool isSaving = false;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                  docId == null ? 'Add Manual FAQ' : 'Respond to Question',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (docId != null)
                      const Text(
                          'Providing an answer here will automatically move this item to the public FAQ board on the Kiosk.',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 15),
                    TextField(
                        controller: questionCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Question',
                            border: OutlineInputBorder()),
                        maxLines: 2),
                    const SizedBox(height: 15),
                    TextField(
                        controller: answerCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Official Answer',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true),
                        maxLines: 5),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed:
                        isSaving ? null : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (questionCtrl.text.isEmpty ||
                              answerCtrl.text.isEmpty) return;

                          setDialogState(() => isSaving = true);
                          try {
                            Map<String, dynamic> payload = {
                              'question': questionCtrl.text.trim(),
                              'answer': answerCtrl.text.trim(),
                              'is_answered': true, // Officially answered now
                              'timestamp': FieldValue.serverTimestamp(),
                            };

                            if (docId == null) {
                              await FirebaseFirestore.instance
                                  .collection('faqs')
                                  .add(payload);
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('faqs')
                                  .doc(docId)
                                  .update(payload);
                            }

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                          } catch (e) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
                            }
                            setDialogState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Publish Answer',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            );
          });
        });
  }
}
