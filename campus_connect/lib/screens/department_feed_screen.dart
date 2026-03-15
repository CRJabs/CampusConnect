import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --- NEW IMPORT ---
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
        color: Colors.white,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: Colors.white, width: 1) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: (size * 2).toInt(),
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

  // --- NEW: Grid Layout Builder ---
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

    if (imageCount == 1) {
      return AspectRatio(aspectRatio: 16 / 9, child: gridImage(imageUrls[0]));
    } else if (imageCount == 2) {
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
    } else if (imageCount == 3) {
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
    } else {
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
                child: Stack(
                  children: [
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
                                          fontWeight: FontWeight.bold))))),
                    ]
                  ],
                )),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF002147),
        foregroundColor: Colors.white,
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
                          height: 450,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              color: Colors.white),
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
                                profileImageUrl, logoText, 240, 64,
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
                                  fontSize: 32, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          // Text(
                          //     '@${orgName.replaceAll(' ', '').toLowerCase()} • $collectionPath',
                          //     style: const TextStyle(
                          //         color: Colors.grey, fontSize: 16)),
                          // const SizedBox(height: 20),
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
                          const Text('Recent Activity',
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
                                        "No activity published yet.",
                                        style: TextStyle(color: Colors.grey)));
                              }
                              // --- UPGRADED: Using ListView.builder for performance ---
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: postSnapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var postData = postSnapshot.data!.docs[index]
                                      .data() as Map<String, dynamic>;
                                  String title =
                                      postData['title'] ?? 'No Title';
                                  String desc = postData['description'] ?? '';

                                  // --- UPGRADED: Multi-image array parsing ---
                                  List<String> imageUrls = [];
                                  if (postData.containsKey('image_urls') &&
                                      postData['image_urls'] is List) {
                                    imageUrls = List<String>.from(
                                        postData['image_urls']);
                                  } else if (postData
                                          .containsKey('image_url') &&
                                      postData['image_url'] != null &&
                                      postData['image_url'].isNotEmpty) {
                                    imageUrls = [postData['image_url']];
                                  }

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
                                                      imageUrls: imageUrls,
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
                                                    fontSize: 20)),
                                            const SizedBox(height: 5),
                                            Text(desc,
                                                style: const TextStyle(
                                                    fontSize: 16, height: 1.5),
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis),

                                            // --- UPGRADED: Dynamic Grid Builder ---
                                            if (imageUrls.isNotEmpty) ...[
                                              const SizedBox(height: 15),
                                              _buildPostImageFeedGrid(
                                                  imageUrls),
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
