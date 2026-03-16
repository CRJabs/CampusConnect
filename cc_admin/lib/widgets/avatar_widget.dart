import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String logoText;
  final double size;
  final double fontSize;
  final bool hasBorder;

  const AvatarWidget({
    super.key,
    required this.imageUrl,
    required this.logoText,
    required this.size,
    required this.fontSize,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    String fallbackLogo = logoText.isNotEmpty ? logoText.substring(0, 1) : 'U';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: Colors.white, width: 3) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              // --- OPTIMIZATION: Drastically reduces RAM usage on Web by downscaling to display size ---
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
              errorBuilder: (c, e, s) => Center(
                  child: Text(fallbackLogo,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold))),
            )
          : Center(
              child: Text(fallbackLogo,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold)),
            ),
    );
  }
}
