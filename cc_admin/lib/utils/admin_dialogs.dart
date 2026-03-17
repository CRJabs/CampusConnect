import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AdminDialogs {
  // --- NEW: Global Delete Confirmation Safety Net ---
  static void confirmDelete(
      BuildContext context, String itemTitle, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Deletion',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete $itemTitle? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogContext);
            },
            child: const Text('Yes, Delete'),
          )
        ],
      ),
    );
  }

  // --- ACCOUNTS MANAGEMENT DIALOGS ---
  static void showAddAccountDialog(BuildContext context) {
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
                    const Text('Register Account',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext))
                  ]),
              content: SizedBox(
                width: 650,
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
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }
                            return DropdownButtonFormField<String>(
                              value: selectedTargetId,
                              decoration: InputDecoration(
                                  labelText: ' ${selectedRole.toUpperCase()}',
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
                          if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                            return;
                          }
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

  static void showEditAccountDialog(
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
              title: const Text('Edit Account Data',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
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
                              .update({'email': emailCtrl.text.trim()});
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

  static void showLoginHistoryDialog(
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
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('No login history found.',
                                      style: TextStyle(color: Colors.grey)));
                            }
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

  // --- DIRECTORY DIALOGS ---
  static void showAddEntityDialog(BuildContext context, String collection) {
    final nameCtrl = TextEditingController();
    final logoCtrl = TextEditingController();
    bool isSaving = false;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Add as new $collection',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 15),
                    TextField(
                        controller: logoCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Acronym (Max 6)',
                            border: OutlineInputBorder()),
                        maxLength: 6),
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
                          if (nameCtrl.text.isEmpty) return;
                          setDialogState(() => isSaving = true);
                          await FirebaseFirestore.instance
                              .collection(collection)
                              .add({
                            'name': nameCtrl.text.trim(),
                            'logo_text': logoCtrl.text.trim().toUpperCase(),
                            'new_notices_count': 0
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

  static void showEditEntityDialog(BuildContext context, String collection,
      String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    bool isSaving = false;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Edit Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', border: OutlineInputBorder())),
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

  // --- DASHBOARD SLOTS & FAQ ---
  static void showConfigureSlotDialog(
      BuildContext context, String slotId, Map<String, dynamic>? currentData) {
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
      0xFF009688
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
                            child: Text('Student Organizations'))
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
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
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
                                    : null));
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
                          if (selectedOrgId == null ||
                              selectedOrgName == null) {
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          await FirebaseFirestore.instance
                              .collection('featured_sources')
                              .doc(slotId)
                              .set({
                            'org_id': selectedOrgId,
                            'org_name': selectedOrgName,
                            'collection': selectedCollection,
                            'badge_color': selectedColor
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

  static void showAnswerFaqDialog(
      BuildContext context, String? docId, Map<String, dynamic>? data) {
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
                              'is_answered': true,
                              'timestamp': FieldValue.serverTimestamp()
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
