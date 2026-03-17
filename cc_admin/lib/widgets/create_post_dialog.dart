import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CreatePostDialog extends StatefulWidget {
  final String targetId;
  final String targetCollection;

  const CreatePostDialog({
    super.key,
    required this.targetId,
    required this.targetCollection,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPosting = false;
  int _uploadingCount = 0;
  List<String> _uploadedImageUrls = [];

  Future<void> _handleMultiImageUpload() async {
    final ImagePicker picker = ImagePicker();

    // --- 100% QUALITY RESTORED ---
    final List<XFile> selectedImages = await picker.pickMultiImage(
      imageQuality: 100,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (selectedImages.isEmpty) return;

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

    if (oversizedSkipped && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Some images were skipped for exceeding the 50MB limit.')));
    }

    if (validImages.isEmpty) return;

    int currentCount = _uploadedImageUrls.length;
    int remainingSlots = 100 - currentCount;

    if (remainingSlots <= 0) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Upload limit of 100 images reached.')));
      return;
    }

    final imagesToUpload = validImages.take(remainingSlots).toList();
    setState(() => _uploadingCount += imagesToUpload.length);

    List<Future<void>> uploadFutures = imagesToUpload.map((imageFile) async {
      try {
        String storagePath =
            '${widget.targetCollection}/${widget.targetId}/post_images/post_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}.jpg';

        final storageRef = FirebaseStorage.instance.ref().child(storagePath);

        if (kIsWeb) {
          final data = await imageFile.readAsBytes();
          await storageRef.putData(
              data, SettableMetadata(contentType: 'image/jpeg'));
        }

        String downloadUrl = await storageRef.getDownloadURL();
        if (mounted) {
          setState(() => _uploadedImageUrls.add(downloadUrl));
        }
      } catch (e) {
        // Silently fail individual images to allow others to finish
      } finally {
        if (mounted) setState(() => _uploadingCount--);
      }
    }).toList();

    await Future.wait(uploadFutures);
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    try {
      await FirebaseFirestore.instance.collection('organization_notices').add({
        'org_id': widget.targetId,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'image_urls': _uploadedImageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection(widget.targetCollection)
          .doc(widget.targetId)
          .update({'new_notices_count': FieldValue.increment(1)});

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Publish Announcement',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Header', border: OutlineInputBorder()),
                    validator: (value) =>
                        value!.isEmpty ? 'Header required' : null),
                const SizedBox(height: 15),
                TextFormField(
                    controller: _descCtrl,
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
                    Text('Attached Media (${_uploadedImageUrls.length}/100)',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002147))),
                    const Spacer(),
                    if (_uploadingCount == 0 && _uploadedImageUrls.length < 100)
                      TextButton.icon(
                          onPressed: _handleMultiImageUpload,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Images'))
                  ],
                ),
                const SizedBox(height: 15),
                if (_uploadedImageUrls.isEmpty && _uploadingCount == 0) ...[
                  InkWell(
                    onTap: _handleMultiImageUpload,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_search,
                                color: Colors.grey, size: 40),
                            SizedBox(height: 10),
                            Text('Add images from gallery (Max 50MB per file)',
                                style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      ),
                    ),
                  )
                ] else ...[
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8)),
                    child: SingleChildScrollView(
                      child: StaggeredGrid.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          ..._uploadedImageUrls.map((url) =>
                              StaggeredGridTile.count(
                                crossAxisCellCount: 1,
                                mainAxisCellCount: 1,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(url,
                                            height: double.infinity,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            cacheWidth: 300)),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                            onTap: () => setState(() =>
                                                _uploadedImageUrls.remove(url)),
                                            child: const CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.white,
                                                child: Icon(Icons.close,
                                                    color: Colors.red,
                                                    size: 14))))
                                  ],
                                ),
                              )),
                          ...List.generate(
                              _uploadingCount,
                              (index) => StaggeredGridTile.count(
                                    crossAxisCellCount: 1,
                                    mainAxisCellCount: 1,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Center(
                                            child: CircularProgressIndicator(
                                                color: Color(0xFF002147),
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
            onPressed: _isPosting || _uploadingCount > 0
                ? null
                : () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002147),
              foregroundColor: Colors.white),
          onPressed: _isPosting || _uploadingCount > 0 ? null : _submitPost,
          child: _isPosting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Publish Post',
                  style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
