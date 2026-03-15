import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'login_screen.dart';

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

  void _showEditProfileDialog(String currentName, String currentBio,
      String currentLogo, String? currentHeaderUrl, String? currentProfileUrl) {
    final nameCtrl = TextEditingController(text: currentName);
    final bioCtrl = TextEditingController(text: currentBio);
    final logoCtrl = TextEditingController(text: currentLogo);
    final formKey = GlobalKey<FormState>();

    String? finalProfileUrl = currentProfileUrl;
    String? finalHeaderUrl = currentHeaderUrl;
    bool isSaving = false;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            bool isUploadingProfile = false;
            bool isUploadingHeader = false;

            Future<void> handleImageUpload(bool isProfileImage) async {
              final ImagePicker picker = ImagePicker();

              // --- OPTIMIZATION: Built-in Compression ---
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 75, // Compress quality to 75%
                maxWidth: 1920, // Prevent massive 4K+ dimension uploads
                maxHeight: 1920,
              );

              if (image == null) return;

              // --- OPTIMIZATION: 50MB Strict Size Check ---
              int fileBytes = await image.length();
              if (fileBytes > 50 * 1024 * 1024) {
                // 50 Megabytes
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Upload failed. Image exceeds the 50MB limit.')));
                }
                return;
              }

              setDialogState(() {
                if (isProfileImage) {
                  isUploadingProfile = true;
                } else {
                  isUploadingHeader = true;
                }
              });

              try {
                String fileName = isProfileImage ? 'profile' : 'header';
                String storagePath =
                    '$_targetCollection/$_targetId/${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                final storageRef =
                    FirebaseStorage.instance.ref().child(storagePath);

                if (kIsWeb) {
                  final data = await image.readAsBytes();
                  await storageRef.putData(
                      data, SettableMetadata(contentType: 'image/jpeg'));
                }

                String downloadUrl = await storageRef.getDownloadURL();

                setDialogState(() {
                  if (isProfileImage) {
                    finalProfileUrl = downloadUrl;
                  } else {
                    finalHeaderUrl = downloadUrl;
                  }
                });
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Upload Error: $e')));
                }
              } finally {
                setDialogState(() {
                  if (isProfileImage) {
                    isUploadingProfile = false;
                  } else {
                    isUploadingHeader = false;
                  }
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Profile Details',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close))
                  ]),
              content: SizedBox(
                  width: 600,
                  child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Information Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF002147))),
                            const SizedBox(height: 15),
                            TextFormField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder()),
                                validator: (value) =>
                                    value!.isEmpty ? 'Name required' : null),
                            const SizedBox(height: 15),
                            TextFormField(
                                controller: logoCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Acronym',
                                    border: OutlineInputBorder()),
                                maxLength: 6),
                            const SizedBox(height: 15),
                            TextFormField(
                                controller: bioCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Bio',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true),
                                maxLines: 4),
                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 15),
                            // const Text('Media Assets',
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 16,
                            //         color: Color(0xFF002147))),
                            const SizedBox(height: 20),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildStandardAvatar(
                                      finalProfileUrl, logoCtrl.text, 100, 30),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        const Text('Profile Photo (Max 50MB)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 5),
                                        const Text('Recommended: 400x400 px',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        const SizedBox(height: 10),
                                        isUploadingProfile
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF002147),
                                                    foregroundColor:
                                                        Colors.white),
                                                onPressed: () =>
                                                    handleImageUpload(true),
                                                icon: const Icon(Icons.upload,
                                                    size: 18),
                                                label:
                                                    const Text('Change Photo'))
                                      ]))
                                ]),
                            const SizedBox(height: 30),
                            const Text('Banner Image (Max 50MB)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade300)),
                                clipBehavior: Clip.antiAlias,
                                child: (finalHeaderUrl != null &&
                                        finalHeaderUrl!.isNotEmpty)
                                    ? Image.network(finalHeaderUrl!,
                                        fit: BoxFit.cover,
                                        cacheWidth: 800,
                                        errorBuilder: (c, e, s) => const Center(
                                            child: Icon(Icons.broken_image)))
                                    : const Center(
                                        child: Icon(Icons.image,
                                            color: Colors.grey, size: 40))),
                            const SizedBox(height: 10),
                            Center(
                                child: isUploadingHeader
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF002147),
                                            foregroundColor: Colors.white),
                                        onPressed: () =>
                                            handleImageUpload(false),
                                        icon: const Icon(
                                            Icons.add_photo_alternate,
                                            size: 18),
                                        label:
                                            const Text('Upload New Banner'))),
                            const SizedBox(height: 10),
                            const Center(
                                child: Text('Recommended 16:9 aspect ratio',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)))
                          ])))),
              actions: [
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002147),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: isSaving ||
                                isUploadingProfile ||
                                isUploadingHeader
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setDialogState(() => isSaving = true);
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection(_targetCollection!)
                                        .doc(_targetId)
                                        .update({
                                      'name': nameCtrl.text.trim(),
                                      'bio': bioCtrl.text.trim(),
                                      'logo_text': logoCtrl.text.trim(),
                                      'profile_image_url': finalProfileUrl,
                                      'header_image_url': finalHeaderUrl
                                    });
                                    if (!dialogContext.mounted) return;
                                    Navigator.pop(dialogContext);
                                  } catch (e) {
                                    if (dialogContext.mounted) {
                                      ScaffoldMessenger.of(dialogContext)
                                          .showSnackBar(SnackBar(
                                              content: Text('Save Error: $e')));
                                    }
                                    setDialogState(() => isSaving = false);
                                  }
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))))
              ],
            );
          });
        });
  }

  void _showCreatePostDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPosting = false;

    List<String> uploadedImageUrls = [];

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            int uploadingCount = 0;

            Future<void> handleMultiImageUpload() async {
              final ImagePicker picker = ImagePicker();

              // --- OPTIMIZATION: Built-in Compression ---
              final List<XFile> selectedImages = await picker.pickMultiImage(
                imageQuality: 70, // Slightly more aggressive for bulk uploads
                maxWidth: 1920,
                maxHeight: 1920,
              );

              if (selectedImages.isEmpty) return;

              // --- OPTIMIZATION: Check all files for 50MB Strict Size Check ---
              List<XFile> validImages = [];
              bool oversizedSkipped = false;

              for (var img in selectedImages) {
                int bytes = await img.length();
                if (bytes <= 50 * 1024 * 1024) {
                  validImages.add(img);
                } else {
                  oversizedSkipped = true;
                }
              }

              if (oversizedSkipped && dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(
                    content: Text(
                        'Some images were skipped for exceeding the 50MB limit.')));
              }

              if (validImages.isEmpty) return;

              // Validate remaining 100 image limit
              int currentCount = uploadedImageUrls.length;
              int remainingSlots = 100 - currentCount;

              if (remainingSlots <= 0) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Upload limit of 100 images reached.')));
                }
                return;
              }

              final List<XFile> imagesToUpload =
                  validImages.take(remainingSlots).toList();

              setDialogState(() => uploadingCount += imagesToUpload.length);

              List<Future<void>> uploadFutures =
                  imagesToUpload.map((imageFile) async {
                try {
                  String storagePath =
                      'organization_notices/$_targetId/post_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}.jpg';
                  final storageRef =
                      FirebaseStorage.instance.ref().child(storagePath);

                  if (kIsWeb) {
                    final data = await imageFile.readAsBytes();
                    await storageRef.putData(
                        data, SettableMetadata(contentType: 'image/jpeg'));
                  }

                  String downloadUrl = await storageRef.getDownloadURL();

                  setDialogState(() {
                    uploadedImageUrls.add(downloadUrl);
                  });
                } catch (e) {
                  // Silently fail individual images to allow others to finish
                } finally {
                  setDialogState(() => uploadingCount--);
                }
              }).toList();

              await Future.wait(uploadFutures);
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Post Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                            controller: titleCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Header',
                                border: OutlineInputBorder()),
                            validator: (value) =>
                                value!.isEmpty ? 'Header required' : null),
                        const SizedBox(height: 15),
                        TextFormField(
                            controller: descCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true),
                            maxLines: 5,
                            validator: (value) =>
                                value!.isEmpty ? 'Description required' : null),
                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                                'Attached Media (${uploadedImageUrls.length}/100)',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF002147))),
                            const Spacer(),
                            if (uploadingCount == 0 &&
                                uploadedImageUrls.length < 100)
                              TextButton.icon(
                                  onPressed: handleMultiImageUpload,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Add Images'))
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (uploadedImageUrls.isEmpty &&
                            uploadingCount == 0) ...[
                          InkWell(
                            onTap: handleMultiImageUpload,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey.shade300,
                                      style: BorderStyle.solid)),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_search,
                                        color: Colors.grey, size: 40),
                                    SizedBox(height: 10),
                                    Text(
                                        'Add images from gallery (Max 50MB per file)',
                                        style: TextStyle(color: Colors.grey))
                                  ],
                                ),
                              ),
                            ),
                          )
                        ] else ...[
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              child: StaggeredGrid.count(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  ...uploadedImageUrls.map((url) =>
                                      StaggeredGridTile.count(
                                        crossAxisCellCount: 1,
                                        mainAxisCellCount: 1,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(url,
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    cacheWidth: 300)),
                                            Positioned(
                                                top: 0,
                                                right: 0,
                                                child: InkWell(
                                                    onTap: () => setDialogState(
                                                        () => uploadedImageUrls
                                                            .remove(url)),
                                                    child: const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Icon(Icons.close,
                                                            color: Colors.red,
                                                            size: 14))))
                                          ],
                                        ),
                                      )),
                                  ...List.generate(
                                      uploadingCount,
                                      (index) => StaggeredGridTile.count(
                                            crossAxisCellCount: 1,
                                            mainAxisCellCount: 1,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF002147),
                                                            strokeWidth: 2))),
                                          ))
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: isPosting || uploadingCount > 0
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002147),
                      foregroundColor: Colors.white),
                  onPressed: isPosting || uploadingCount > 0
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() => isPosting = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('organization_notices')
                                  .add({
                                'org_id': _targetId,
                                'title': titleCtrl.text.trim(),
                                'description': descCtrl.text.trim(),
                                'image_urls': uploadedImageUrls,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              await FirebaseFirestore.instance
                                  .collection(_targetCollection!)
                                  .doc(_targetId)
                                  .update({
                                'new_notices_count': FieldValue.increment(1)
                              });
                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            } catch (e) {
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext)
                                    .showSnackBar(
                                        SnackBar(content: Text('Error: $e')));
                              }
                              setDialogState(() => isPosting = false);
                            }
                          }
                        },
                  child: isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2))
                      : const Text('Publish Post',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF002147))));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
          appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: const Color(0xFF002147),
              foregroundColor: Colors.white),
          body: Center(
              child: Text(_errorMessage,
                  style: const TextStyle(color: Colors.red))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: const Color(0xFF002147),
          foregroundColor: Colors.white,
          title: Image.network('../assets/logo.png',
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
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
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
          child: _buildStandardAvatar(profileImageUrl, logoText, 240, 64,
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
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      // const SizedBox(height: 5),
                      // Text(
                      //     '@${orgName.replaceAll(' ', '').toLowerCase()} • $_targetCollection',
                      //     style:
                      //         const TextStyle(color: Colors.grey, fontSize: 16))
                    ])),
                OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF002147),
                        side: const BorderSide(color: Color(0xFF002147)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10)),
                    onPressed: () => _showEditProfileDialog(
                        orgName, bio, logoText, headerUrl, profileImageUrl),
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
            _buildStandardAvatar(
                profileImageUrl, logoText.substring(0, 1), 40, 14),
            const SizedBox(width: 15),
            Expanded(
                child: InkWell(
                    onTap: _showCreatePostDialog,
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
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                              _buildStandardAvatar(profileImageUrl,
                                  logoText.substring(0, 1), 40, 14),
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
                                  onPressed: () => FirebaseFirestore.instance
                                      .collection('organization_notices')
                                      .doc(post.id)
                                      .delete())
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
                        _buildStandardAvatar(
                            profileImageUrl, logoText.substring(0, 1), 40, 14),
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
                                        const SizedBox())),
                          )),
                    ]
                  ],
                ),
              ),
            ),
          );
        });
  }
}
