import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'department_feed_screen.dart';
import 'post_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isHomeTabActive = true;
  String _activeExploreTab = 'administrations';

  Future<Map<String, dynamic>> _fetchEntityData(String id) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) return doc.data()!;

      doc = await FirebaseFirestore.instance
          .collection('departments')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) return doc.data()!;

      doc = await FirebaseFirestore.instance
          .collection('administrations')
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) return doc.data()!;
    } catch (e) {
      return {};
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainTabToggle(),
          const SizedBox(height: 20),
          if (_isHomeTabActive) ...[
            _buildHeroCarousel(),
            const SizedBox(height: 20),
            const Text('Latest Announcements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildLatestAnnouncementsSection(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // const Text(
            //     '___________________________________________________________________________________________',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 20),
            _buildGlobalLiveFeed(),
          ] else ...[
            // const Text('Explore Directory',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 20),
            _buildDynamicListSection(context),
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
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
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

  Widget _buildHeroCarousel() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('highlights')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 500,
                child: Center(
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
                height: 500.0,
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
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(cTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    // const SizedBox(height: 5),
                    Text(cDesc,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostDetailScreen(
                                    title: pTitle,
                                    desc: pDesc,
                                    imageUrls: passImages,
                                    orgName: 'Featured Highlight',
                                    timeText: 'Pinned')));
                      },
                      child: const Text('View Details →',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Widget _buildLatestAnnouncementsSection() {
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
          var displayDocs = allDocs.take(4).toList();

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
                  // --- UPGRADED: Add FutureBuilder to fetch specific organization's profile picture ---
                  return FutureBuilder<Map<String, dynamic>>(
                      future: _fetchEntityData(orgId),
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
                              logoText);
                        }

                        var postData = postSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        return _buildInfoCard(
                            orgName,
                            postData['title'] ?? 'No Title',
                            postData['description'] ?? '',
                            postData,
                            profileUrl,
                            logoText);
                      });
                });

            rowChildren.add(Expanded(child: cardWidget));

            if (i < displayDocs.length - 1) {
              rowChildren.add(const SizedBox(width: 15));
            }
          }

          return Row(
            children: rowChildren,
          );
        });
  }

  // --- UPGRADED: Removed badgeColor, added profileUrl and logoText parameters ---
  Widget _buildInfoCard(String source, String title, String desc,
      Map<String, dynamic>? postData, String? profileUrl, String logoText) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- UPGRADED: Replaced colored pill with Avatar profile block ---
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: (profileUrl != null && profileUrl.trim().isNotEmpty)
                    ? Image.network(profileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Center(
                            child: Text(
                                logoText.isNotEmpty
                                    ? logoText.substring(0, 1)
                                    : 'U',
                                style: const TextStyle(
                                    color: Color(0xFF002147),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))))
                    : Center(
                        child: Text(
                            logoText.isNotEmpty
                                ? logoText.substring(0, 1)
                                : 'U',
                            style: const TextStyle(
                                color: Color(0xFF002147),
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(source,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                    postData['image_url'].isNotEmpty) {
                  imageUrls = [postData['image_url']];
                }

                String timeText = 'Recently';
                if (postData['timestamp'] != null) {
                  DateTime date = (postData['timestamp'] as Timestamp).toDate();
                  timeText = "${date.month}/${date.day}/${date.year}";
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostDetailScreen(
                            title: title,
                            desc: desc,
                            imageUrls: imageUrls,
                            orgName: source,
                            timeText: timeText)));
              },
              child: const Text('Read More →',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildGlobalLiveFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('organization_notices')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        return ListView.builder(
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
                postData['image_url'].isNotEmpty) {
              imageUrls = [postData['image_url']];
            }

            String timeText = 'Recently';
            if (postData['timestamp'] != null) {
              DateTime date = (postData['timestamp'] as Timestamp).toDate();
              timeText = "${date.month}/${date.day}/${date.year}";
            }

            return FutureBuilder<Map<String, dynamic>>(
                future: _fetchEntityData(orgId),
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
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                  title: title,
                                  desc: desc,
                                  imageUrls: imageUrls,
                                  orgName: orgName,
                                  timeText: timeText))),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  clipBehavior: Clip.antiAlias,
                                  child: (profileUrl != null &&
                                          profileUrl.trim().isNotEmpty)
                                      ? Image.network(profileUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Center(
                                              child: Text(logoText.isNotEmpty ? logoText.substring(0, 1) : 'U',
                                                  style: const TextStyle(
                                                      color: Color(0xFF002147),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold))))
                                      : Center(
                                          child: Text(logoText.isNotEmpty ? logoText.substring(0, 1) : 'U',
                                              style: const TextStyle(
                                                  color: Color(0xFF002147),
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                ),
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
                              ],
                            ),
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
                });
          },
        );
      },
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

  Widget _buildDynamicListSection(BuildContext context) {
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
                _buildExploreTabButton('Administration', 'administrations'),
                _buildExploreTabButton('Departments', 'departments'),
                _buildExploreTabButton('Organizations', 'organizations'),
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
                return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF002147))));
              }
              if (snapshot.hasError) {
                return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(child: Text('Error: ${snapshot.error}')));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.all(40.0),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      clipBehavior: Clip.antiAlias,
                      child: (profileUrl != null && profileUrl.trim().isNotEmpty)
                          ? Image.network(profileUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Center(
                                  child: Text(
                                      logoText.length > 4
                                          ? logoText.substring(0, 4)
                                          : logoText,
                                      style: const TextStyle(
                                          color: Color(0xFF002147),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))))
                          : Center(
                              child: Text(
                                  logoText.length > 4
                                      ? logoText.substring(0, 4)
                                      : logoText,
                                  style: const TextStyle(
                                      color: Color(0xFF002147),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))),
                    ),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
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
                                    fontWeight: FontWeight.bold)),
                          ),
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

  Widget _buildExploreTabButton(String title, String targetCollection) {
    bool isActive = _activeExploreTab == targetCollection;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeExploreTab = targetCollection),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
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
                      color:
                          isActive ? const Color(0xFF002147) : Colors.grey))),
        ),
      ),
    );
  }
}
