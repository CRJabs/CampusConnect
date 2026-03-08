import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'department_feed_screen.dart';
import 'post_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isHomeTabActive = true;
  bool _isShowingDepartments = true;

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
            const SizedBox(height: 40),
            const Text('Featured Announcements',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildLatestAnnouncementsSection(),
            const SizedBox(height: 40),
            const Text('Live Global Feed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildGlobalLiveFeed(),
          ] else ...[
            const Text('Explore Directory',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
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

  Widget _buildHeroCarousel() {
    final List<Map<String, String>> carouselItems = [
      {
        'title': 'UB Days 2026 is Here!',
        'desc':
            'Visit the Official Medal Tally website here to see your department\'s standings!',
        'img':
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=1200'
      },
      {
        'title': 'University of Bohol\'s 80th Charter Day',
        'desc':
            'Join us in celebrating eight decades of Scholarship, Character, and Service.',
        'img':
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=1200'
      },
      {
        'title': 'Student Services Satisfaction Survey',
        'desc': 'Help us serve you better by taking this quick survey.',
        'img':
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=1200'
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
          height: 350.0,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
          viewportFraction: 1.0),
      items: carouselItems.map((item) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF002147),
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
                image: NetworkImage(item['img']!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.darken)),
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(item['title']!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(item['desc']!,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
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
                              title: item['title']!,
                              desc: item['desc']!,
                              orgName: 'Featured Banner',
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
  }

  Widget _buildLatestAnnouncementsSection() {
    return Row(
      children: [
        Expanded(
            child: _buildInfoCard(
                'University of Bohol',
                'Campus Wide Advisory',
                'Important update regarding campus entry protocols.',
                Colors.red)),
        const SizedBox(width: 15),
        Expanded(
            child: _buildInfoCard(
                'UB SPS',
                'Clearance Requirements',
                '1st Semester clearance guidelines are now available.',
                Colors.blue)),
        const SizedBox(width: 15),
        Expanded(
            child: _buildInfoCard(
                'UB NSSG',
                'Student Assembly',
                'Join the mandatory supreme student government assembly.',
                Colors.green)),
        const SizedBox(width: 15),
        Expanded(
            child: _buildInfoCard(
                'UB CSO',
                'Accreditation Deadline',
                'Final call for campus student organizations accreditation.',
                Colors.orange)),
      ],
    );
  }

  Widget _buildInfoCard(
      String source, String title, String desc, Color badgeColor) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: badgeColor, borderRadius: BorderRadius.circular(20)),
            child: Text(source,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
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
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostDetailScreen(
                          title: title,
                          desc: desc,
                          orgName: source,
                          timeText: 'Featured')));
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
              child: Text("No general announcements at this time.",
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
            String? imageUrl = postData['image_url'];

            String timeText = 'Recently';
            if (postData['timestamp'] != null) {
              DateTime date = (postData['timestamp'] as Timestamp).toDate();
              timeText = "${date.month}/${date.day}/${date.year}";
            }

            return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('organizations')
                    .doc(orgId)
                    .get(),
                builder: (context, orgSnapshot) {
                  String orgName = "Campus Organization";
                  String? profileUrl;
                  String logoText = "UB";

                  if (orgSnapshot.hasData && orgSnapshot.data!.exists) {
                    var orgData =
                        orgSnapshot.data!.data() as Map<String, dynamic>;
                    orgName = orgData['name'] ?? orgName;
                    profileUrl = orgData['profile_image_url'];
                    logoText = orgData['logo_text'] ?? 'UB';
                  } else {
                    FirebaseFirestore.instance
                        .collection('departments')
                        .doc(orgId)
                        .get()
                        .then((depDoc) {
                      if (depDoc.exists && mounted) {
                        // Safe state update logic if needed
                      }
                    });
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
                                  imageUrl: imageUrl,
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
                                      color: Color(0xFF002147),
                                      shape: BoxShape.circle),
                                  clipBehavior: Clip.antiAlias,
                                  child: (profileUrl != null &&
                                          profileUrl.isNotEmpty)
                                      ? Image.network(profileUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Center(
                                              child: Text(
                                                  logoText.substring(0, 1),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14))))
                                      : Center(
                                          child: Text(logoText.substring(0, 1),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14))),
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
                                      errorBuilder: (c, e, s) =>
                                          const SizedBox())),
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

  Widget _buildDynamicListSection(BuildContext context) {
    String currentCollection =
        _isShowingDepartments ? 'departments' : 'organizations';

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
                _buildExploreTabButton('Departments', true),
                _buildExploreTabButton('Organizations', false),
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
                  int newNotices = data['new_notices_count'] ?? 0;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                        backgroundColor: const Color(0xFF002147),
                        child: Text(logoText,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14))),
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
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DepartmentFeedScreen(
                                orgId: docs[index].id,
                                collectionPath: currentCollection))),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTabButton(String title, bool isDepartmentTab) {
    bool isActive = _isShowingDepartments == isDepartmentTab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _isShowingDepartments = isDepartmentTab),
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
