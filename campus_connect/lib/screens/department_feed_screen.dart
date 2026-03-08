import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_detail_screen.dart';

class DepartmentFeedScreen extends StatelessWidget {
  final String orgId;
  final String collectionPath;

  const DepartmentFeedScreen(
      {super.key, required this.orgId, required this.collectionPath});

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
          ? Image.network(imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (c, e, s) => Center(
                  child: Text(logoText,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold))))
          : Center(
              child: Text(logoText,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Back to Dashboard', style: TextStyle(fontSize: 16)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(orgId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF002147)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String orgName = data['name'] ?? 'Unnamed Organization';
          String logoText = data['logo_text'] ?? 'UB';
          String bio =
              data['bio'] ?? 'Welcome to our official CampusConnect page!';
          String? headerUrl = data['header_image_url'];
          String? profileImageUrl = data['profile_image_url'];

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: 1400,
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
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              color: Color(0xFF002147)),
                          clipBehavior: Clip.antiAlias,
                          child:
                              (headerUrl != null && headerUrl.trim().isNotEmpty)
                                  ? Stack(fit: StackFit.expand, children: [
                                      Image.network(headerUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                              const SizedBox()),
                                      Container(
                                          color: Colors.black.withOpacity(0.3))
                                    ])
                                  : null,
                        ),
                        Positioned(
                            bottom: -50,
                            left: 40,
                            child: _buildStandardAvatar(
                                profileImageUrl, logoText, 120, 32,
                                hasBorder: true)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 60, left: 40, right: 40, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orgName,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                              '@${orgName.replaceAll(' ', '').toLowerCase()} • $collectionPath',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16)),
                          const SizedBox(height: 20),
                          Text(bio,
                              style:
                                  const TextStyle(fontSize: 16, height: 1.5)),
                        ],
                      ),
                    ),
                    const Divider(thickness: 8, color: Color(0xFFF0F2F5)),
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recent Announcements',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('organization_notices')
                                .where('org_id', isEqualTo: orgId)
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, postSnapshot) {
                              if (postSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator()));
                              }
                              if (!postSnapshot.hasData ||
                                  postSnapshot.data!.docs.isEmpty) {
                                return Container(
                                    padding: const EdgeInsets.all(40),
                                    alignment: Alignment.center,
                                    child: const Text(
                                        "No announcements published yet.",
                                        style: TextStyle(color: Colors.grey)));
                              }

                              return Column(
                                children: postSnapshot.data!.docs.map((post) {
                                  var postData =
                                      post.data() as Map<String, dynamic>;
                                  String title =
                                      postData['title'] ?? 'No Title';
                                  String desc = postData['description'] ?? '';
                                  String? imageUrl = postData['image_url'];

                                  String timeText = 'Recently';
                                  if (postData['timestamp'] != null) {
                                    DateTime date =
                                        (postData['timestamp'] as Timestamp)
                                            .toDate();
                                    timeText =
                                        "${date.month}/${date.day}/${date.year}";
                                  }

                                  return Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.transparent,
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1)),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PostDetailScreen(
                                                      title: title,
                                                      desc: desc,
                                                      imageUrl: imageUrl,
                                                      orgName: orgName,
                                                      timeText: timeText))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                _buildStandardAvatar(
                                                    profileImageUrl,
                                                    logoText.substring(0, 1),
                                                    40,
                                                    14),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(orgName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(timeText,
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            Text(title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            const SizedBox(height: 5),
                                            Text(desc,
                                                style: const TextStyle(
                                                    fontSize: 15, height: 1.5),
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            if (imageUrl != null &&
                                                imageUrl.isNotEmpty) ...[
                                              const SizedBox(height: 15),
                                              ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: 400,
                                                      errorBuilder: (c, e, s) =>
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
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
