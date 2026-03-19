import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';

class PostDetailScreen extends StatelessWidget {
  final String title;
  final String desc;
  final List<String> imageUrls;
  final String orgName;
  final String timeText;
  final String? profileUrl;
  final String logoText;

  const PostDetailScreen({
    super.key,
    required this.title,
    required this.desc,
    required this.imageUrls,
    required this.orgName,
    required this.timeText,
    this.profileUrl,
    this.logoText = 'UB',
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      // Fluid padding for mobile compatibility
      insetPadding: EdgeInsets.all(isDesktop ? 40 : 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        // --- FLUID CONSTRAINTS ---
        constraints: const BoxConstraints(maxWidth: 900),
        padding: EdgeInsets.all(isDesktop ? 30 : 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarWidget(
                      imageUrl: profileUrl,
                      logoText: logoText,
                      size: 40,
                      fontSize: 14),
                  const SizedBox(width: 10),
                  Expanded(
                    // Prevent text overflow on small phones
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orgName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(timeText,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12))
                        ]),
                  ),
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
              Text(desc, style: const TextStyle(fontSize: 16, height: 1.6)),
              if (imageUrls.isNotEmpty) ...[
                const SizedBox(height: 30),
                ...imageUrls.map((url) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: isDesktop ? 400 : 250,
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF002147),
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                              errorBuilder: (c, e, s) => const SizedBox())),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
