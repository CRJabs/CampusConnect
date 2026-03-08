import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Accounts, Directory, Settings
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFF002147), // Dark Navy Background
          elevation: 0,
          automaticallyImplyLeading: false,

          title: Row(
            children: [
              const SizedBox(width: 20),
              Image.network(
                '../assets/logo.png', // White Logo
                height: 40,
                errorBuilder: (context, error, stackTrace) => const Text(
                    'CampusConnect Admin',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          actions: [
            // Super Admin Badge
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

            // The Pill Tabs Container
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
                  // --- THIS IS THE FIX: Removes the default Material 3 52px gap! ---
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  // ----------------------------------------------------------------
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(
                        0xFF002147), // Navy background for active pill
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white, // White text when active
                  unselectedLabelColor:
                      Colors.black87, // Dark text when inactive
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
                      Icon(Icons.build_circle, size: 16),
                      SizedBox(width: 8),
                      Text('Settings',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold))
                    ])),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 30),

            // Logout Button (White text on Navy)
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
                _buildFutureTab(),
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
                      if (selectedRole == 'department' ||
                          selectedRole == 'organization')
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(selectedRole == 'department'
                                  ? 'departments'
                                  : 'organizations')
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
                          if ((selectedRole == 'department' ||
                                  selectedRole == 'organization') &&
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
                                        : 'organizations',
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
  // TAB 2: DEPARTMENTS & ORGS MANAGEMENT
  // ==========================================
  bool _isShowingDepartments = true;

  Widget _buildDirectoryTab() {
    return StatefulBuilder(builder: (context, setTabState) {
      String currentCollection =
          _isShowingDepartments ? 'departments' : 'organizations';

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
                      _showAddEntityDialog(context, currentCollection),
                  icon: const Icon(Icons.add_business),
                  label: Text(
                      'Add New ${_isShowingDepartments ? 'Department' : 'Organization'}',
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
                  Expanded(
                      child: InkWell(
                          onTap: () =>
                              setTabState(() => _isShowingDepartments = true),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: _isShowingDepartments
                                              ? const Color(0xFF002147)
                                              : Colors.transparent,
                                          width: 3))),
                              child: Center(
                                  child: Text('Academic Departments',
                                      style: TextStyle(
                                          fontWeight: _isShowingDepartments
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _isShowingDepartments
                                              ? const Color(0xFF002147)
                                              : Colors.grey)))))),
                  Expanded(
                      child: InkWell(
                          onTap: () =>
                              setTabState(() => _isShowingDepartments = false),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: !_isShowingDepartments
                                              ? const Color(0xFF002147)
                                              : Colors.transparent,
                                          width: 3))),
                              child: Center(
                                  child: Text('Student Organizations',
                                      style: TextStyle(
                                          fontWeight: !_isShowingDepartments
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: !_isShowingDepartments
                                              ? const Color(0xFF002147)
                                              : Colors.grey)))))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(currentCollection)
                      .orderBy('name')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                      return Center(
                          child: Text('No $currentCollection found.'));
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
                                          child: Text(logoText,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold))))
                                  : Center(
                                      child: Text(logoText,
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
                                        currentCollection,
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
                                          .collection(currentCollection)
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
  // TAB 3: CONSTRUCTION
  // ==========================================
  Widget _buildFutureTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('System Settings & Analytics',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          SizedBox(height: 10),
          Text('Reserved for future implementation.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
