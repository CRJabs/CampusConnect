import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'login_screen.dart';

import '../widgets/create_post_dialog.dart';
import '../widgets/edit_profile_dialog.dart';
import '../utils/admin_dialogs.dart';
import '../widgets/avatar_widget.dart'; // --- NEW AVATAR WIDGET ---

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
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing)
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF002147))));
    if (_errorMessage.isNotEmpty)
      return Scaffold(
          appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: const Color(0xFF002147),
              foregroundColor: Colors.white),
          body: Center(
              child: Text(_errorMessage,
                  style: const TextStyle(color: Colors.red))));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFF002147),
          foregroundColor: Colors.white,
          title: Image.asset('../assets/logo.png',
              height: 60,
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
          if (!snapshot.hasData || !snapshot.data!.exists)
            return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String orgName = data['name'] ?? 'Unnamed Organization';
          String logoText = data['logo_text'] ?? 'UB';
          String bio = data['bio'] ?? 'Bio not set up yet.';
          String? headerUrl = data['header_image_url'];
          String? profileImageUrl = data['profile_image_url'];

          return SingleChildScrollView(
            child: Center(
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
    return Stack(clipBehavior: Clip.none, children: [
      Container(
          height: 500,
          width: double.infinity,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Color(0xFF002147)),
          clipBehavior: Clip.antiAlias,
          child: hasHeader
              ? Stack(fit: StackFit.expand, children: [
                  Image.network(headerUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 1600,
                      errorBuilder: (c, e, s) => const SizedBox()),
                  Container(color: Colors.black.withOpacity(0.3))
                ])
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
      String? headerUrl, String? profileImageUrl) {
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
                .limit(30)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text("No announcements published yet.",
                        style: TextStyle(color: Colors.grey)));

              final posts = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var post = posts[index];
                  var postData = post.data() as Map<String, dynamic>;
                  String title = postData['title'] ?? 'No Title';
                  String desc = postData['description'] ?? '';

                  List<String> imageUrls = [];
                  if (postData.containsKey('image_urls') &&
                      postData['image_urls'] is List)
                    imageUrls = List<String>.from(postData['image_urls']);
                  else if (postData.containsKey('image_url') &&
                      postData['image_url'] != null &&
                      postData['image_url'].isNotEmpty)
                    imageUrls = [postData['image_url']];

                  String timeText = 'Recently';
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
                      onTap: () => _showPostDetailsDialog(
                          title,
                          desc,
                          imageUrls,
                          orgName,
                          logoText,
                          profileImageUrl,
                          timeText),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              AvatarWidget(
                                  imageUrl: profileImageUrl,
                                  logoText: logoText,
                                  size: 40,
                                  fontSize: 14),
                              const SizedBox(width: 10),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(orgName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(timeText,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12))
                                  ]),
                              const Spacer(),
                              IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => AdminDialogs.confirmDelete(
                                          context, "Post: $title", () {
                                        FirebaseFirestore.instance
                                            .collection('organization_notices')
                                            .doc(post.id)
                                            .delete();
                                      }))
                            ]),
                            const SizedBox(height: 15),
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 5),
                            Text(desc,
                                style:
                                    const TextStyle(fontSize: 16, height: 1.5),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                            if (imageUrls.isNotEmpty) ...[
                              const SizedBox(height: 15),
                              _buildPostImageFeedGrid(imageUrls),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostImageFeedGrid(List<String> imageUrls) {
    int imageCount = imageUrls.length;
    ClipRRect gridImage(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
            cacheWidth: 500,
            errorBuilder: (c, e, s) =>
                const Center(child: Icon(Icons.broken_image))));

    if (imageCount == 1)
      return AspectRatio(aspectRatio: 16 / 9, child: gridImage(imageUrls[0]));
    else if (imageCount == 2)
      return AspectRatio(
          aspectRatio: 16 / 9,
          child: StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: gridImage(imageUrls[0])),
                StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: gridImage(imageUrls[1]))
              ]));
    else if (imageCount == 3)
      return AspectRatio(
          aspectRatio: 16 / 9,
          child: StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: gridImage(imageUrls[0])),
                StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: gridImage(imageUrls[1])),
                StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: gridImage(imageUrls[2]))
              ]));
    else
      return AspectRatio(
          aspectRatio: 16 / 9,
          child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridImage(imageUrls[0])),
                StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: gridImage(imageUrls[1])),
                          StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: gridImage(imageUrls[2]))
                        ])),
                StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: Stack(children: [
                      gridImage(imageUrls[3]),
                      if (imageCount > 4) ...[
                        Positioned.fill(
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text('+${imageCount - 3}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold)))))
                      ]
                    ]))
              ]));
  }

  void _showPostDetailsDialog(
      String title,
      String desc,
      List<String> imageUrls,
      String orgName,
      String logoText,
      String? profileImageUrl,
      String timeText) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 900,
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AvatarWidget(
                            imageUrl: profileImageUrl,
                            logoText: logoText,
                            size: 40,
                            fontSize: 14),
                        const SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(orgName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(timeText,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12))
                            ]),
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 15),
                    Text(desc,
                        style: const TextStyle(fontSize: 16, height: 1.6)),
                    if (imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      ...imageUrls.map((url) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(url,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  errorBuilder: (c, e, s) =>
                                      const SizedBox())))),
                    ]
                  ],
                ),
              ),
            ),
          );
        });
  }
}
