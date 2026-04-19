import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

import '../widgets/create_post_dialog.dart';
import '../widgets/edit_profile_dialog.dart';
import '../utils/activity_logger.dart';
import '../utils/admin_dialogs.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/recent_posts_feed.dart';

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
      if (user == null) throw Exception("No user logged in.");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('target_id')) {
        throw Exception("Account not linked to an organization.");
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
    await ActivityLogger.log('Organization editor logged out',
        source: 'Authentication');
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
          toolbarHeight: 75,
          backgroundColor: const Color(0xFF002147),
          foregroundColor: Colors.white,
          title: Image.asset('assets/logo.png',
              height: 45,
              errorBuilder: (context, error, stackTrace) => const Text(
                  'CampusConnect',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          actions: [
            TextButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout',
                    style: TextStyle(color: Colors.white))),
            const SizedBox(width: 20)
          ]),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(_targetCollection!)
            .doc(_targetId!)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String orgName = data['name'] ?? 'Unnamed Organization';
          String logoText = data['logo_text'] ?? 'UB';
          String bio = data['bio'] ?? 'Bio not set up yet.';
          String? headerUrl = data['header_image_url'];
          String? profileImageUrl = data['profile_image_url'];
          String? bgImageUrl = data['bg_image_url'];

          return Stack(
            children: [
              if (bgImageUrl != null && bgImageUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    bgImageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 1920,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: const Color(0xFFF0F2F5));
                    },
                    errorBuilder: (c, e, s) =>
                        Container(color: const Color(0xFFF0F2F5)),
                  ),
                ),
              if (bgImageUrl != null && bgImageUrl.isNotEmpty)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ),
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      width: 1080,
                      margin: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 20),
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
                          _buildProfileHeader(
                              headerUrl, logoText, profileImageUrl),
                          _buildBioSection(orgName, bio, logoText, headerUrl,
                              profileImageUrl, bgImageUrl),
                          const Divider(thickness: 8, color: Color(0xFFF0F2F5)),
                          _buildCreatePostSection(logoText, profileImageUrl),
                          const Divider(thickness: 1, color: Color(0xFFF0F2F5)),
                          RecentPostsFeed(
                            targetId: _targetId!,
                            orgName: orgName,
                            logoText: logoText,
                            profileImageUrl: profileImageUrl,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      String? headerUrl, String logoText, String? profileImageUrl) {
    bool hasHeader = headerUrl != null && headerUrl.trim().isNotEmpty;
    return Stack(clipBehavior: Clip.none, children: [
      Container(
          height: 500,
          width: double.infinity,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Color(0xFF002147)),
          child: hasHeader
              ? ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(headerUrl,
                        fit: BoxFit.cover,
                        cacheWidth: 1600,
                        errorBuilder: (c, e, s) => const SizedBox()),
                    Container(color: Colors.black.withOpacity(0.3))
                  ]),
                )
              : null),
      Positioned(
          bottom: -50,
          left: 40,
          child: AvatarWidget(
              imageUrl: profileImageUrl,
              logoText: logoText,
              size: 240,
              fontSize: 64,
              hasBorder: true))
    ]);
  }

  Widget _buildBioSection(String orgName, String bio, String logoText,
      String? headerUrl, String? profileImageUrl, String? bgImageUrl) {
    return Padding(
        padding:
            const EdgeInsets.only(top: 60, left: 40, right: 40, bottom: 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                              fontSize: 32, fontWeight: FontWeight.bold))
                    ])),
                OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF002147),
                        side: const BorderSide(color: Color(0xFF002147)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10)),
                    onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => EditProfileDialog(
                              targetCollection: _targetCollection!,
                              targetId: _targetId!,
                              currentName: orgName,
                              currentBio: bio,
                              currentLogo: logoText,
                              currentHeaderUrl: headerUrl,
                              currentProfileUrl: profileImageUrl,
                              currentBgUrl: bgImageUrl,
                            )),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile Details',
                        style: TextStyle(fontWeight: FontWeight.bold)))
              ]),
          const SizedBox(height: 20),
          Text(bio, style: const TextStyle(fontSize: 16, height: 1.5))
        ]));
  }

  Widget _buildCreatePostSection(String logoText, String? profileImageUrl) {
    return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Publish post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AvatarWidget(
                imageUrl: profileImageUrl,
                logoText: logoText,
                size: 40,
                fontSize: 14),
            const SizedBox(width: 15),
            Expanded(
                child: InkWell(
                    onTap: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CreatePostDialog(
                            targetId: _targetId!,
                            targetCollection: _targetCollection!)),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey.shade300)),
                        child: const Text("What's happening? Post an update...",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16)))))
          ])
        ]));
  }
}
