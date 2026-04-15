import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'department_feed_screen.dart';
import 'post_detail_screen.dart';

import '../utils/entity_cache.dart';
import '../widgets/avatar_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isHomeTabActive = true;
  String _activeExploreTab = 'administrations';

  int _postLimit = 10;

  // --- FLUID UI HELPER FUNCTION ---
  // Smoothly scales values between minSize and maxSize based on the screen width
  double getFluidSize(double currentWidth,
      {required double minSize, required double maxSize}) {
    const double minScreen = 400.0; // Mobile phone width
    const double maxScreen = 1400.0; // Desktop/Kiosk width

    double t = (currentWidth - minScreen) / (maxScreen - minScreen);
    t = t.clamp(0.0, 1.0); // Ensures 't' stays strictly between 0 and 1

    return minSize + (maxSize - minSize) * t;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // bool isDesktop = screenWidth > 1400; // Kept for structural layout changes

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        // Smoothly scales top/bottom padding between 20 and 40
        vertical: getFluidSize(screenWidth, minSize: 20, maxSize: 40),
        // Smoothly scales left/right padding between 32 and 512
        horizontal: getFluidSize(screenWidth, minSize: 32, maxSize: 128),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainTabToggle(),
          const SizedBox(height: 20),
          if (_isHomeTabActive) ...[
            _buildHeroCarousel(screenWidth),
            SizedBox(
                height: getFluidSize(screenWidth, minSize: 20, maxSize: 40)),
            Text('Featured Posts',
                style: TextStyle(
                    fontSize:
                        getFluidSize(screenWidth, minSize: 16, maxSize: 22),
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildLatestAnnouncementsSection(screenWidth),
            SizedBox(
                height: getFluidSize(screenWidth, minSize: 20, maxSize: 40)),
            const SizedBox(height: 20),
            _buildGlobalLiveFeed(screenWidth),
          ] else ...[
            _buildDynamicListSection(context, screenWidth),
          ]
        ],
      ),
    );
  }

  Widget _buildMainTabToggle() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _mainTabButton('Home', _isHomeTabActive,
                () => setState(() => _isHomeTabActive = true)),
            _mainTabButton('Explore', !_isHomeTabActive,
                () => setState(() => _isHomeTabActive = false)),
          ],
        ),
      ),
    );
  }

  Widget _mainTabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
            color: isActive ? const Color(0xFF002147) : Colors.transparent,
            borderRadius: BorderRadius.circular(25)),
        child: Text(title,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }

  Widget _buildHeroCarousel(double screenWidth) {
    bool isDesktop = screenWidth > 1400;

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('highlights')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                height: getFluidSize(screenWidth, minSize: 250, maxSize: 400),
                child: const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF002147))));
          }

          List<Map<String, dynamic>> carouselItems = [];

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            carouselItems = [
              {
                'carousel_title': 'Welcome to CampusConnect',
                'carousel_desc':
                    'The central hub for all campus announcements and organizations.',
                'carousel_image_url':
                    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=1200',
                'post_title': 'Welcome to CampusConnect',
                'post_desc':
                    'Check the Admin Portal to add your own custom highlights to this carousel!',
              }
            ];
          } else {
            carouselItems = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          }

          return CarouselSlider(
            options: CarouselOptions(
                height: getFluidSize(screenWidth, minSize: 250, maxSize: 500),
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 6),
                enlargeCenterPage: true,
                viewportFraction: 1.0),
            items: carouselItems.map((item) {
              String cTitle = item['carousel_title'] ?? 'Announcement';
              String cDesc = item['carousel_desc'] ?? '';
              String cImageUrl = item['carousel_image_url'] ??
                  'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=1200';
              String pTitle = item['post_title'] ?? cTitle;
              String pDesc = item['post_desc'] ?? cDesc;
              String? pImageUrl = item['post_image_url'];

              List<String> passImages =
                  pImageUrl != null && pImageUrl.isNotEmpty ? [pImageUrl] : [];

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF002147),
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                      image: NetworkImage(cImageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.darken)),
                ),
                padding: EdgeInsets.all(
                    getFluidSize(screenWidth, minSize: 20, maxSize: 40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(cTitle,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: getFluidSize(screenWidth,
                                minSize: 20, maxSize: 36),
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    if (isDesktop)
                      Text(cDesc,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18)),
                    if (isDesktop) const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              horizontal: getFluidSize(screenWidth,
                                  minSize: 14, maxSize: 24),
                              vertical: getFluidSize(screenWidth,
                                  minSize: 7, maxSize: 12))),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => PostDetailScreen(
                                title: pTitle,
                                desc: pDesc,
                                imageUrls: passImages,
                                orgName: 'Featured Highlight',
                                timeText: 'Pinned',
                                logoText: 'UB'));
                      },
                      child: Text('View Details →',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getFluidSize(screenWidth,
                                  minSize: 12, maxSize: 14))),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget _buildLatestAnnouncementsSection(double screenWidth) {
    bool isDesktop = screenWidth > 1400;

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('featured_sources')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF002147)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Admin has not configured featured accounts yet.',
                    style: TextStyle(color: Colors.grey)));
          }

          var allDocs = snapshot.data!.docs.toList();
          allDocs.removeWhere((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['org_id'] == null || data['org_id'].toString().isEmpty;
          });

          allDocs.shuffle();
          var displayDocs = allDocs.take(3).toList();

          if (displayDocs.isEmpty) {
            return const Center(
                child: Text('No valid featured accounts configured.',
                    style: TextStyle(color: Colors.grey)));
          }

          List<Widget> rowChildren = [];

          for (int i = 0; i < displayDocs.length; i++) {
            var slotData = displayDocs[i].data() as Map<String, dynamic>;
            String orgId = slotData['org_id'] ?? '';
            String orgName = slotData['org_name'] ?? 'Unknown Source';

            Widget cardWidget = StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('organization_notices')
                    .where('org_id', isEqualTo: orgId)
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, postSnapshot) {
                  return FutureBuilder<Map<String, dynamic>>(
                      future: EntityCache.getEntityData(orgId),
                      builder: (context, entitySnapshot) {
                        String? profileUrl;
                        String logoText = "UB";

                        if (entitySnapshot.hasData &&
                            entitySnapshot.data!.isNotEmpty) {
                          profileUrl =
                              entitySnapshot.data!['profile_image_url'];
                          logoText = entitySnapshot.data!['logo_text'] ?? 'UB';
                        }

                        if (!postSnapshot.hasData ||
                            postSnapshot.data!.docs.isEmpty) {
                          return _buildInfoCard(
                              orgName,
                              'Awaiting Announcements',
                              'This organization has not published any recent updates.',
                              null,
                              profileUrl,
                              logoText,
                              orgId,
                              screenWidth);
                        }

                        var postData = postSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        return _buildInfoCard(
                            orgName,
                            postData['title'] ?? 'No Title',
                            postData['description'] ?? '',
                            postData,
                            profileUrl,
                            logoText,
                            orgId,
                            screenWidth);
                      });
                });

            if (isDesktop) {
              rowChildren.add(Expanded(child: cardWidget));
            } else {
              rowChildren.add(Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 15),
                  child: cardWidget));
            }

            if (isDesktop && i < displayDocs.length - 1) {
              rowChildren.add(const SizedBox(width: 15));
            }
          }

          // Uses structural isDesktop to decide between Row and ScrollView
          if (isDesktop) {
            return Row(children: rowChildren);
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: rowChildren),
            );
          }
        });
  }

  Widget _buildInfoCard(
      String source,
      String title,
      String desc,
      Map<String, dynamic>? postData,
      String? profileUrl,
      String logoText,
      String orgId,
      double screenWidth) {
    return Container(
      height: getFluidSize(screenWidth, minSize: 200, maxSize: 230),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                  imageUrl: profileUrl,
                  logoText: logoText,
                  size: getFluidSize(screenWidth, minSize: 30, maxSize: 35),
                  fontSize: 12),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(source,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      getFluidSize(screenWidth, minSize: 14, maxSize: 16)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(desc,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize:
                      getFluidSize(screenWidth, minSize: 12, maxSize: 13)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          if (postData != null)
            InkWell(
              onTap: () {
                List<String> imageUrls = [];
                if (postData.containsKey('image_urls') &&
                    postData['image_urls'] is List) {
                  imageUrls = List<String>.from(postData['image_urls']);
                } else if (postData.containsKey('image_url') &&
                    postData['image_url'] != null &&
                    postData['image_url'].isNotEmpty)
                  imageUrls = [postData['image_url']];

                String timeText = 'Recently';
                if (postData['timestamp'] != null) {
                  DateTime date = (postData['timestamp'] as Timestamp).toDate();
                  timeText = "${date.month}/${date.day}/${date.year}";
                }

                showDialog(
                    context: context,
                    builder: (context) => PostDetailScreen(
                        title: title,
                        desc: desc,
                        imageUrls: imageUrls,
                        orgName: source,
                        timeText: timeText,
                        profileUrl: profileUrl,
                        logoText: logoText));
              },
              child: Text('Read More →',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          getFluidSize(screenWidth, minSize: 12, maxSize: 14))),
            ),
        ],
      ),
    );
  }

  Widget _buildGlobalLiveFeed(double screenWidth) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('organization_notices')
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
          return const Center(
              child: Text("No posts at this time.",
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
                var postData = posts[index].data() as Map<String, dynamic>;
                String orgId = postData['org_id'] ?? '';
                String title = postData['title'] ?? 'No Title';
                String desc = postData['description'] ?? '';

                List<String> imageUrls = [];
                if (postData.containsKey('image_urls') &&
                    postData['image_urls'] is List) {
                  imageUrls = List<String>.from(postData['image_urls']);
                } else if (postData.containsKey('image_url') &&
                    postData['image_url'] != null &&
                    postData['image_url'].isNotEmpty)
                  imageUrls = [postData['image_url']];

                String timeText = 'Recently';
                if (postData['timestamp'] != null) {
                  DateTime date = (postData['timestamp'] as Timestamp).toDate();
                  timeText = "${date.month}/${date.day}/${date.year}";
                }

                return FutureBuilder<Map<String, dynamic>>(
                    future: EntityCache.getEntityData(orgId),
                    builder: (context, entitySnapshot) {
                      String orgName = "Campus Organization";
                      String? profileUrl;
                      String logoText = "UB";

                      if (entitySnapshot.hasData &&
                          entitySnapshot.data!.isNotEmpty) {
                        var orgData = entitySnapshot.data!;
                        orgName = orgData['name'] ?? orgName;
                        profileUrl = orgData['profile_image_url'];
                        logoText = orgData['logo_text'] ?? 'UB';
                      }

                      return Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => PostDetailScreen(
                                    title: title,
                                    desc: desc,
                                    imageUrls: imageUrls,
                                    orgName: orgName,
                                    timeText: timeText,
                                    profileUrl: profileUrl,
                                    logoText: logoText));
                          },
                          child: Padding(
                            padding: EdgeInsets.all(getFluidSize(screenWidth,
                                minSize: 15, maxSize: 20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AvatarWidget(
                                        imageUrl: profileUrl,
                                        logoText: logoText,
                                        size: getFluidSize(screenWidth,
                                            minSize: 35, maxSize: 40),
                                        fontSize: 12),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(orgName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: getFluidSize(
                                                        screenWidth,
                                                        minSize: 12,
                                                        maxSize: 14)),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            Text(timeText,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11))
                                          ]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: getFluidSize(screenWidth,
                                            minSize: 14, maxSize: 20))),
                                const SizedBox(height: 2),
                                Text(desc,
                                    style: TextStyle(
                                        fontSize: getFluidSize(screenWidth,
                                            minSize: 12, maxSize: 16),
                                        height: 1.4),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                                if (imageUrls.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildPostImageFeedGrid(imageUrls),
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    });
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
          ],
        );
      },
    );
  }

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

  Widget _buildDynamicListSection(BuildContext context, double screenWidth) {
    String currentCollection = _activeExploreTab;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2))),
            child: Row(
              children: [
                _buildExploreTabButton(
                    'Administration', 'administrations', screenWidth),
                _buildExploreTabButton(
                    'Departments', 'departments', screenWidth),
                _buildExploreTabButton(
                    'Organizations', 'organizations', screenWidth),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(currentCollection)
                .orderBy('name')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                    padding: EdgeInsets.all(getFluidSize(screenWidth,
                        minSize: 20.0, maxSize: 40.0)),
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF002147))));
              }
              if (snapshot.hasError) {
                return Padding(
                    padding: EdgeInsets.all(getFluidSize(screenWidth,
                        minSize: 20.0, maxSize: 40.0)),
                    child: Center(child: Text('Error: ${snapshot.error}')));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                    padding: EdgeInsets.all(getFluidSize(screenWidth,
                        minSize: 20.0, maxSize: 40.0)),
                    child: Center(
                        child: Text('No data found in "$currentCollection".',
                            style: const TextStyle(color: Colors.grey))));
              }

              final docs = snapshot.data!.docs;

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade200, height: 1),
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  String name = data['name'] ?? 'Unknown';
                  String logoText = data['logo_text'] ?? 'UB';
                  int newNotices = int.tryParse(
                          data['new_notices_count']?.toString() ?? '0') ??
                      0;
                  String? profileUrl = data['profile_image_url'];

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal:
                            getFluidSize(screenWidth, minSize: 10, maxSize: 20),
                        vertical:
                            getFluidSize(screenWidth, minSize: 5, maxSize: 10)),
                    leading: AvatarWidget(
                        imageUrl: profileUrl,
                        logoText: logoText,
                        size:
                            getFluidSize(screenWidth, minSize: 35, maxSize: 45),
                        fontSize: 12),
                    title: Text(name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: getFluidSize(screenWidth,
                                minSize: 12, maxSize: 16))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (newNotices > 0)
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text('$newNotices new',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))),
                        const SizedBox(width: 10),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      if (newNotices > 0) {
                        FirebaseFirestore.instance
                            .collection(currentCollection)
                            .doc(docs[index].id)
                            .update({'new_notices_count': 0}).catchError((e) =>
                                debugPrint(
                                    "Badge reset failed or blocked by rules."));
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DepartmentFeedScreen(
                                  orgId: docs[index].id,
                                  collectionPath: currentCollection)));
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTabButton(
      String title, String targetCollection, double screenWidth) {
    bool isActive = _activeExploreTab == targetCollection;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeExploreTab = targetCollection),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: getFluidSize(screenWidth, minSize: 12, maxSize: 15)),
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
                      fontSize:
                          getFluidSize(screenWidth, minSize: 12, maxSize: 14),
                      color: isActive ? const Color(0xFF002147) : Colors.grey),
                  textAlign: TextAlign.center)),
        ),
      ),
    );
  }
}
