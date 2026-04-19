import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'avatar_widget.dart';
import '../utils/admin_dialogs.dart';
import '../utils/activity_logger.dart';

class RecentPostsFeed extends StatefulWidget {
  final String targetId;
  final String orgName;
  final String logoText;
  final String? profileImageUrl;

  const RecentPostsFeed({
    super.key,
    required this.targetId,
    required this.orgName,
    required this.logoText,
    this.profileImageUrl,
  });

  @override
  State<RecentPostsFeed> createState() => _RecentPostsFeedState();
}

class _RecentPostsFeedState extends State<RecentPostsFeed> {
  int _postLimit = 10;

  @override
  Widget build(BuildContext context) {
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
                .where('org_id', isEqualTo: widget.targetId)
                .orderBy('timestamp', descending: true)
                .limit(_postLimit)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _postLimit == 10) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text("No announcements published yet.",
                        style: TextStyle(color: Colors.grey)));
              }

              final posts = snapshot.data!.docs;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListView.builder(
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
                          postData['image_urls'] is List) {
                        imageUrls = List<String>.from(postData['image_urls']);
                      } else if (postData.containsKey('image_url') &&
                          postData['image_url'] != null &&
                          postData['image_url'].isNotEmpty) {
                        imageUrls = [postData['image_url']];
                      }

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
                            side: BorderSide(
                                color: Colors.grey.shade200, width: 1)),
                        child: InkWell(
                          onTap: () => _showPostDetailsDialog(
                              title,
                              desc,
                              imageUrls,
                              widget.orgName,
                              widget.logoText,
                              widget.profileImageUrl,
                              timeText),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  AvatarWidget(
                                      imageUrl: widget.profileImageUrl,
                                      logoText: widget.logoText,
                                      size: 40,
                                      fontSize: 14),
                                  const SizedBox(width: 10),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.orgName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(timeText,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12))
                                      ]),
                                  const Spacer(),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () =>
                                          AdminDialogs.confirmDelete(
                                              context, "Post: $title", () async {
                                            await FirebaseFirestore.instance
                                                .collection(
                                                    'organization_notices')
                                                .doc(post.id)
                                                .delete();
                                            await ActivityLogger.log(
                                              'Deleted announcement: $title',
                                              source: 'Posts',
                                              targetId: post.id,
                                            );
                                          }))
                                ]),
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
                  ),
                  if (posts.length >= _postLimit)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF002147),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: BorderSide(color: Colors.grey.shade300),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            _postLimit += 10;
                          });
                        },
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Load More Posts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostImageFeedGrid(List<String> imageUrls) {
    int count = imageUrls.length;

    // --- UX OPTIMIZATION: Progressive Loading Indicator for 100% Quality Images ---
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
              minHeight: maxWidth / 1.78,
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
                                  // Adds smooth progress spinner inside the clicked popup too!
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 300,
                                      color: Colors.grey.shade100,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: const Color(0xFF002147),
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
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
