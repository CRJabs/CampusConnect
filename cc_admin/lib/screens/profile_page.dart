import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _targetCollection;
  String? _targetId;
  bool _isInitializing = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRoutingLink();
  }

  Future<void> _fetchUserRoutingLink() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in.");
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('target_id')) {
        throw Exception(
            "Your account is not linked to any specific department or organization.");
      }

      setState(() {
        _targetCollection = userDoc.get('target_collection');
        _targetId = userDoc.get('target_id');
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isInitializing = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Widget _buildStandardAvatar(
      String? imageUrl, String logoText, double size, double fontSize,
      {bool hasBorder = false}) {
    bool hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF002147),
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: Colors.white, width: 5) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(logoText,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold))),
            )
          : Center(
              child: Text(logoText,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold))),
    );
  }

  // --- REVERTED: Now uses text fields for URLs instead of file pickers ---
  void _showEditProfileDialog(String currentName, String currentBio,
      String currentLogo, String? currentHeaderUrl, String? currentProfileUrl) {
    final nameCtrl = TextEditingController(text: currentName);
    final bioCtrl = TextEditingController(text: currentBio);
    final logoCtrl = TextEditingController(text: currentLogo);
    final profileUrlCtrl = TextEditingController(text: currentProfileUrl ?? '');
    final headerUrlCtrl = TextEditingController(text: currentHeaderUrl ?? '');

    final formKey = GlobalKey<FormState>();
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
                  const Text('Edit Profile Details',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed:
                          isSaving ? null : () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close)),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Information Details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF002147))),
                        const SizedBox(height: 15),
                        TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Organization Name',
                                border: OutlineInputBorder()),
                            validator: (value) =>
                                value!.isEmpty ? 'Name cannot be empty' : null),
                        const SizedBox(height: 15),
                        TextFormField(
                            controller: logoCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Acronym',
                                border: OutlineInputBorder()),
                            maxLength: 4),
                        const SizedBox(height: 15),
                        TextFormField(
                            controller: bioCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Bio / Description',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true),
                            maxLines: 4),
                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 15),
                        const Text('Profile / Header Images',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF002147))),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: profileUrlCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Profile Photo URL (Web Link)',
                              border: OutlineInputBorder(),
                              hintText: 'https://example.com/logo.png'),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: headerUrlCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Header Image URL (Web Link)',
                              border: OutlineInputBorder(),
                              hintText: 'https://example.com/banner.png'),
                        ),
                      ],
                    ),
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
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              setDialogState(() => isSaving = true);
                              try {
                                await FirebaseFirestore.instance
                                    .collection(_targetCollection!)
                                    .doc(_targetId)
                                    .update({
                                  'name': nameCtrl.text.trim(),
                                  'bio': bioCtrl.text.trim(),
                                  'logo_text': logoCtrl.text.trim(),
                                  'profile_image_url':
                                      profileUrlCtrl.text.trim(),
                                  'header_image_url': headerUrlCtrl.text.trim(),
                                });

                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);
                              } catch (e) {
                                if (!dialogContext.mounted) return;
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                        SnackBar(content: Text('Error: $e')));
                                setDialogState(() => isSaving = false);
                              }
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            );
          });
        });
  }

  // --- REVERTED: Now uses text field for Image URL instead of file picker ---
  void _showCreatePostDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();

    final formKey = GlobalKey<FormState>();
    bool isPosting = false;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Publish Announcement',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                            controller: titleCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Announcement Title',
                                border: OutlineInputBorder()),
                            validator: (value) =>
                                value!.isEmpty ? 'Title is required' : null),
                        const SizedBox(height: 15),
                        TextFormField(
                            controller: descCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Full Description',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true),
                            maxLines: 5,
                            validator: (value) => value!.isEmpty
                                ? 'Description is required'
                                : null),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: imageUrlCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Attach Image URL (Optional)',
                              border: OutlineInputBorder(),
                              hintText: 'https://example.com/poster.jpg'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed:
                        isPosting ? null : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black),
                  onPressed: isPosting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() => isPosting = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('organization_notices')
                                  .add({
                                'org_id': _targetId,
                                'title': titleCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'image_url': imageUrlCtrl.text.trim(),
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              await FirebaseFirestore.instance
                                  .collection(_targetCollection!)
                                  .doc(_targetId)
                                  .update({
                                'new_notices_count': FieldValue.increment(1),
                              });

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            } catch (e) {
                              if (!dialogContext.mounted) return;
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
                              setDialogState(() => isPosting = false);
                            }
                          }
                        },
                  child: isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2))
                      : const Text('Post Announcement',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }

  void _showPostDetailsDialog(
      String title,
      String desc,
      String? imageUrl,
      String orgName,
      String logoText,
      String? profileImageUrl,
      String timeText) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 700,
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStandardAvatar(
                            profileImageUrl, logoText.substring(0, 1), 40, 14),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orgName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(timeText,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                    const SizedBox(height: 15),
                    Text(desc,
                        style: const TextStyle(fontSize: 16, height: 1.6)),
                    if (imageUrl != null && imageUrl.isNotEmpty) ...[
                      const SizedBox(height: 25),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(imageUrl,
                              fit: BoxFit.contain, width: double.infinity)),
                    ]
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF002147))));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
          appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: const Color(0xFF002147),
              foregroundColor: Colors.white),
          body: Center(
              child: Text(_errorMessage,
                  style: const TextStyle(color: Colors.red))));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF002147),
        foregroundColor: Colors.white,
        title: Image.network(
          '../assets/logo.png',
          height: 45,
          errorBuilder: (context, error, stackTrace) => const Text(
              'CampusConnect',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        actions: [
          TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label:
                  const Text('Logout', style: TextStyle(color: Colors.white))),
          const SizedBox(width: 20),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(_targetCollection!)
            .doc(_targetId!)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Error loading profile data.'));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String orgName = data['name'] ?? 'Unnamed Organization';
          String logoText = data['logo_text'] ?? 'UB';
          String bio = data['bio'] ??
              'Welcome to our official CampusConnect page! We have not set up a bio yet.';
          String? headerUrl = data['header_image_url'];
          String? profileImageUrl = data['profile_image_url'];

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: 1600,
                margin:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(headerUrl, logoText, profileImageUrl),
                    _buildBioSection(
                        orgName, bio, logoText, headerUrl, profileImageUrl),
                    const Divider(thickness: 8, color: Color(0xFFF0F2F5)),
                    _buildCreatePostSection(logoText, profileImageUrl),
                    const Divider(thickness: 1, color: Color(0xFFF0F2F5)),
                    _buildRecentPostsFeed(orgName, logoText, profileImageUrl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      String? headerUrl, String logoText, String? profileImageUrl) {
    bool hasHeader = headerUrl != null && headerUrl.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 500,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: Color(0xFF002147),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasHeader
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(headerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const SizedBox()),
                    Container(color: Colors.black.withOpacity(0.3)),
                  ],
                )
              : null,
        ),
        Positioned(
          bottom: -50,
          left: 40,
          child: _buildStandardAvatar(profileImageUrl, logoText, 240, 64,
              hasBorder: true),
        ),
      ],
    );
  }

  Widget _buildBioSection(String orgName, String bio, String logoText,
      String? headerUrl, String? profileImageUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 40, right: 40, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orgName,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                        '@${orgName.replaceAll(' ', '').toLowerCase()} • $_targetCollection',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF002147),
                    side: const BorderSide(color: Color(0xFF002147)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15)),
                onPressed: () => _showEditProfileDialog(
                    orgName, bio, logoText, headerUrl, profileImageUrl),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile Details',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(bio, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCreatePostSection(String logoText, String? profileImageUrl) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Publish post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStandardAvatar(
                  profileImageUrl, logoText.substring(0, 1), 40, 14),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: _showCreatePostDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: const Text(
                        "What's happening on campus? Post an update...",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPostsFeed(
      String orgName, String logoText, String? profileImageUrl) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('organization_notices')
                .where('org_id', isEqualTo: _targetId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()));
              if (snapshot.hasError)
                return Container(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error loading feed: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text("No announcements published yet.",
                        style: TextStyle(color: Colors.grey)));

              final posts = snapshot.data!.docs;

              return Column(
                children: posts.map((post) {
                  var postData = post.data() as Map<String, dynamic>;
                  String title = postData['title'] ?? 'No Title';
                  String desc = postData['description'] ?? '';
                  String? imageUrl = postData['image_url'];

                  String timeText = 'Just now';
                  if (postData['timestamp'] != null) {
                    DateTime date =
                        (postData['timestamp'] as Timestamp).toDate();
                    timeText = "${date.month}/${date.day}/${date.year}";
                  }

                  return Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: Colors.grey.shade200, width: 1)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showPostDetailsDialog(title, desc, imageUrl,
                          orgName, logoText, profileImageUrl, timeText),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildStandardAvatar(profileImageUrl,
                                    logoText.substring(0, 1), 40, 14),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(orgName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(timeText,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () => FirebaseFirestore.instance
                                        .collection('organization_notices')
                                        .doc(post.id)
                                        .delete()),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text(desc,
                                style:
                                    const TextStyle(fontSize: 15, height: 1.5),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                            if (imageUrl != null && imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 15),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 400,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox())),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
