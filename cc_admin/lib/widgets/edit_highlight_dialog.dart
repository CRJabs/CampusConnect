import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/image_uploader.dart';

class EditHighlightDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const EditHighlightDialog({super.key, this.docId, this.data});

  @override
  State<EditHighlightDialog> createState() => _EditHighlightDialogState();
}

class _EditHighlightDialogState extends State<EditHighlightDialog> {
  late TextEditingController _carouselTitleCtrl;
  late TextEditingController _carouselDescCtrl;
  late TextEditingController _postTitleCtrl;
  late TextEditingController _postDescCtrl;

  String? _finalCarouselImageUrl;
  String? _finalPostImageUrl;

  bool _isSaving = false;
  bool _isUploadingCarousel = false;
  bool _isUploadingPost = false;

  @override
  void initState() {
    super.initState();
    _carouselTitleCtrl =
        TextEditingController(text: widget.data?['carousel_title']);
    _carouselDescCtrl =
        TextEditingController(text: widget.data?['carousel_desc']);
    _postTitleCtrl = TextEditingController(text: widget.data?['post_title']);
    _postDescCtrl = TextEditingController(text: widget.data?['post_desc']);
    _finalCarouselImageUrl = widget.data?['carousel_image_url'];
    _finalPostImageUrl = widget.data?['post_image_url'];
  }

  @override
  void dispose() {
    _carouselTitleCtrl.dispose();
    _carouselDescCtrl.dispose();
    _postTitleCtrl.dispose();
    _postDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpload(bool isCarousel) async {
    setState(() =>
        isCarousel ? _isUploadingCarousel = true : _isUploadingPost = true);

    String prefix = isCarousel ? 'carousel' : 'post';
    String storagePath =
        'highlights/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    String? uploadedUrl =
        await ImageUploader.pickAndUploadSingle(context, storagePath);

    if (uploadedUrl != null && mounted) {
      setState(() {
        if (isCarousel) {
          _finalCarouselImageUrl = uploadedUrl;
        } else {
          _finalPostImageUrl = uploadedUrl;
        }
      });
    }

    if (mounted) {
      setState(() =>
          isCarousel ? _isUploadingCarousel = false : _isUploadingPost = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
            widget.docId == null
                ? 'Create New Highlight'
                : 'Edit Highlight Details',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSaving ? null : () => Navigator.pop(context))
      ]),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Carousel Display',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF002147))),
              const SizedBox(height: 10),
              TextField(
                  controller: _carouselTitleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Carousel Main Heading',
                      border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(
                  controller: _carouselDescCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Carousel Subheading',
                      border: OutlineInputBorder())),
              const SizedBox(height: 15),
              Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)),
                  clipBehavior: Clip.antiAlias,
                  child: (_finalCarouselImageUrl != null)
                      ? Image.network(_finalCarouselImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Center(child: Icon(Icons.broken_image)))
                      : const Center(
                          child:
                              Icon(Icons.image, color: Colors.grey, size: 40))),
              const SizedBox(height: 10),
              Center(
                  child: _isUploadingCarousel
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002147),
                              foregroundColor: Colors.white),
                          onPressed: () => _handleUpload(true),
                          icon: const Icon(Icons.add_photo_alternate, size: 18),
                          label: const Text('Upload Carousel Banner (16:9)'))),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              const Text('2. Post Details',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF002147))),
              const SizedBox(height: 10),
              TextField(
                  controller: _postTitleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Post Heading', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(
                  controller: _postDescCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true),
                  maxLines: 5),
              const SizedBox(height: 15),
              Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)),
                  clipBehavior: Clip.antiAlias,
                  child: (_finalPostImageUrl != null)
                      ? Image.network(_finalPostImageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) =>
                              const Center(child: Icon(Icons.broken_image)))
                      : const Center(
                          child:
                              Icon(Icons.image, color: Colors.grey, size: 40))),
              const SizedBox(height: 10),
              Center(
                  child: _isUploadingPost
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002147),
                              foregroundColor: Colors.white),
                          onPressed: () => _handleUpload(false),
                          icon: const Icon(Icons.add_photo_alternate, size: 18),
                          label: const Text('Upload Image'))),
            ],
          ),
        ),
      ),
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
                onPressed: _isSaving || _isUploadingCarousel || _isUploadingPost
                    ? null
                    : () async {
                        if (_carouselTitleCtrl.text.isEmpty ||
                            _carouselDescCtrl.text.isEmpty ||
                            _postTitleCtrl.text.isEmpty ||
                            _postDescCtrl.text.isEmpty ||
                            _finalCarouselImageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Please fill out all required text fields and ensure a Carousel Banner is uploaded.')));
                          return;
                        }
                        setState(() => _isSaving = true);
                        try {
                          Map<String, dynamic> payload = {
                            'carousel_title': _carouselTitleCtrl.text.trim(),
                            'carousel_desc': _carouselDescCtrl.text.trim(),
                            'post_title': _postTitleCtrl.text.trim(),
                            'post_desc': _postDescCtrl.text.trim(),
                            'carousel_image_url': _finalCarouselImageUrl,
                            'post_image_url': _finalPostImageUrl,
                            'timestamp': FieldValue.serverTimestamp(),
                          };

                          if (widget.docId == null) {
                            await FirebaseFirestore.instance
                                .collection('highlights')
                                .add(payload);
                          } else {
                            await FirebaseFirestore.instance
                                .collection('highlights')
                                .doc(widget.docId)
                                .update(payload);
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Save Error: $e')));
                          }
                          setState(() => _isSaving = false);
                        }
                      },
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publish Highlight',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))))
      ],
    );
  }
}
