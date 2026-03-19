import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_detail_screen.dart';
import '../widgets/avatar_widget.dart';

class DepartmentFeedScreen extends StatefulWidget {
  final String orgId;
  final String collectionPath;

  const DepartmentFeedScreen(
      {super.key, required this.orgId, required this.collectionPath});

  @override
  State<DepartmentFeedScreen> createState() => _DepartmentFeedScreenState();
}

class _DepartmentFeedScreenState extends State<DepartmentFeedScreen> {
  int _postLimit = 10;

  Widget _buildPostImageFeedGrid(List<String> imageUrls) {
    int count = imageUrls.length;

    Widget buildNetworkImage(String url, BoxFit fit) {
      return Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF002147),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (c, e, s) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    if (count == 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: maxWidth / 1.54,
              maxHeight: maxWidth / 1.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey.shade900,
                width: double.infinity,
                child: buildNetworkImage(imageUrls[0], BoxFit.contain),
              ),
            ),
          );
        },
      );
    }

    if (count == 2) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          children: [
            Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildNetworkImage(imageUrls[0], BoxFit.cover))),
            const SizedBox(width: 8),
            Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildNetworkImage(imageUrls[1], BoxFit.cover))),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildNetworkImage(imageUrls[0], BoxFit.cover)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: buildNetworkImage(imageUrls[1], BoxFit.cover))),
                const SizedBox(height: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        buildNetworkImage(imageUrls[2], BoxFit.cover),
                        if (count > 3)
                          Container(
                            color: Colors.black.withOpacity(0.6),
                            alignment: Alignment.center,
                            child: Text(
                              '+${count - 3}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF002147),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Back to Dashboard', style: TextStyle(fontSize: 16)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.collectionPath)
            .doc(widget.orgId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF002147)));
          if (!snapshot.hasData || !snapshot.data!.exists)
            return const Center(child: Text('Profile not found.'));

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String orgName = data['name'] ?? 'Unnamed Organization';
          String logoText = data['logo_text'] ?? 'UB';
          String bio =
              data['bio'] ?? 'Welcome to our official CampusConnect page!';
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
                      return Container(color: const Color(0xFF002147));
                    },
                    errorBuilder: (c, e, s) => Container(color: Colors.white),
                  ),
                ),
              if (bgImageUrl != null && bgImageUrl.isNotEmpty)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                    child: Container(color: Colors.black.withOpacity(0.15)),
                  ),
                ),
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      // --- FLUID CONSTRAINTS ---
                      constraints: const BoxConstraints(maxWidth: 1400),
                      margin: EdgeInsets.symmetric(
                          vertical: isDesktop ? 40 : 20,
                          horizontal: isDesktop ? 20 : 10),
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
                                height: isDesktop ? 450 : 200,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    color: Color(0xFF002147)),
                                child: (headerUrl != null &&
                                        headerUrl.trim().isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                        child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(headerUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      const SizedBox()),
                                              Container(
                                                  color: Colors.black
                                                      .withOpacity(0.3))
                                            ]),
                                      )
                                    : null,
                              ),
                              Positioned(
                                  bottom: isDesktop ? -50 : -30,
                                  left: isDesktop ? 40 : 20,
                                  child: AvatarWidget(
                                      imageUrl: profileImageUrl,
                                      logoText: logoText,
                                      size: isDesktop ? 240 : 100,
                                      fontSize: isDesktop ? 64 : 32,
                                      hasBorder: true)),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: isDesktop ? 60 : 40,
                                left: isDesktop ? 40 : 20,
                                right: isDesktop ? 40 : 20,
                                bottom: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(orgName,
                                    style: TextStyle(
                                        fontSize: isDesktop ? 32 : 24,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 10),
                                Text(bio,
                                    style: const TextStyle(
                                        fontSize: 16, height: 1.5)),
                              ],
                            ),
                          ),
                          const Divider(thickness: 8, color: Color(0xFFF0F2F5)),
                          Padding(
                            padding: EdgeInsets.all(isDesktop ? 40 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Recent Activity',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('organization_notices')
                                      .where('org_id', isEqualTo: widget.orgId)
                                      .orderBy('timestamp', descending: true)
                                      .limit(_postLimit)
                                      .snapshots(),
                                  builder: (context, postSnapshot) {
                                    if (postSnapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        _postLimit == 10)
                                      return const Center(
                                          child: Padding(
                                              padding: EdgeInsets.all(20),
                                              child:
                                                  CircularProgressIndicator()));
                                    if (!postSnapshot.hasData ||
                                        postSnapshot.data!.docs.isEmpty) {
                                      return Container(
                                          padding: const EdgeInsets.all(40),
                                          alignment: Alignment.center,
                                          child: const Text(
                                              "No activity published yet.",
                                              style: TextStyle(
                                                  color: Colors.grey)));
                                    }

                                    final posts = postSnapshot.data!.docs;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: posts.length,
                                          itemBuilder: (context, index) {
                                            var postData = posts[index].data()
                                                as Map<String, dynamic>;
                                            String title =
                                                postData['title'] ?? 'No Title';
                                            String desc =
                                                postData['description'] ?? '';

                                            List<String> imageUrls = [];
                                            if (postData.containsKey(
                                                    'image_urls') &&
                                                postData['image_urls'] is List)
                                              imageUrls = List<String>.from(
                                                  postData['image_urls']);
                                            else if (postData
                                                    .containsKey('image_url') &&
                                                postData['image_url'] != null &&
                                                postData['image_url']
                                                    .isNotEmpty)
                                              imageUrls = [
                                                postData['image_url']
                                              ];

                                            String timeText = 'Recently';
                                            if (postData['timestamp'] != null) {
                                              DateTime date =
                                                  (postData['timestamp']
                                                          as Timestamp)
                                                      .toDate();
                                              timeText =
                                                  "${date.month}/${date.day}/${date.year}";
                                            }

                                            return Card(
                                              color: Colors.white,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  side: BorderSide(
                                                      color:
                                                          Colors.grey.shade200,
                                                      width: 1)),
                                              child: InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          PostDetailScreen(
                                                              title: title,
                                                              desc: desc,
                                                              imageUrls:
                                                                  imageUrls,
                                                              orgName: orgName,
                                                              timeText:
                                                                  timeText,
                                                              profileUrl:
                                                                  profileImageUrl,
                                                              logoText:
                                                                  logoText));
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          AvatarWidget(
                                                              imageUrl:
                                                                  profileImageUrl,
                                                              logoText:
                                                                  logoText,
                                                              size: 40,
                                                              fontSize: 14),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(orgName,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                                Text(timeText,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      Text(title,
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      20)),
                                                      const SizedBox(height: 5),
                                                      Text(desc,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  height: 1.5),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      if (imageUrls
                                                          .isNotEmpty) ...[
                                                        const SizedBox(
                                                            height: 15),
                                                        _buildPostImageFeedGrid(
                                                            imageUrls),
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        if (posts.length >= _postLimit)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 20),
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor:
                                                    const Color(0xFF002147),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                side: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _postLimit += 10;
                                                });
                                              },
                                              icon:
                                                  const Icon(Icons.expand_more),
                                              label: const Text(
                                                  'Load More Posts',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                            ),
                                          )
                                      ],
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
