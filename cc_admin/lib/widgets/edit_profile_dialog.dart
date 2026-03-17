import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/image_uploader.dart';

class EditProfileDialog extends StatefulWidget {
  final String targetCollection;
  final String targetId;
  final String currentName;
  final String currentBio;
  final String currentLogo;
  final String? currentHeaderUrl;
  final String? currentProfileUrl;
  final String? currentBgUrl; // --- NEW: Added Background URL Parameter ---

  const EditProfileDialog({
    super.key,
    required this.targetCollection,
    required this.targetId,
    required this.currentName,
    required this.currentBio,
    required this.currentLogo,
    this.currentHeaderUrl,
    this.currentProfileUrl,
    this.currentBgUrl,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _logoCtrl;
  final _formKey = GlobalKey<FormState>();

  String? _finalProfileUrl;
  String? _finalHeaderUrl;
  String? _finalBgUrl; // --- NEW: Track new background ---

  bool _isSaving = false;
  bool _isUploadingProfile = false;
  bool _isUploadingHeader = false;
  bool _isUploadingBg = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _bioCtrl = TextEditingController(text: widget.currentBio);
    _logoCtrl = TextEditingController(text: widget.currentLogo);
    _finalProfileUrl = widget.currentProfileUrl;
    _finalHeaderUrl = widget.currentHeaderUrl;
    _finalBgUrl = widget.currentBgUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  // --- UPDATED: Takes an integer to handle 3 different upload targets ---
  Future<void> _handleUpload(int imageType) async {
    setState(() {
      if (imageType == 0)
        _isUploadingProfile = true;
      else if (imageType == 1)
        _isUploadingHeader = true;
      else
        _isUploadingBg = true;
    });

    String fileName =
        imageType == 0 ? 'profile' : (imageType == 1 ? 'header' : 'background');
    String storagePath =
        '${widget.targetCollection}/${widget.targetId}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    String? uploadedUrl =
        await ImageUploader.pickAndUploadSingle(context, storagePath);

    if (uploadedUrl != null && mounted) {
      setState(() {
        if (imageType == 0)
          _finalProfileUrl = uploadedUrl;
        else if (imageType == 1)
          _finalHeaderUrl = uploadedUrl;
        else
          _finalBgUrl = uploadedUrl;
      });
    }

    if (mounted) {
      setState(() {
        if (imageType == 0)
          _isUploadingProfile = false;
        else if (imageType == 1)
          _isUploadingHeader = false;
        else
          _isUploadingBg = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Edit Profile Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close))
      ]),
      content: SizedBox(
          width: 600,
          child: Form(
              key: _formKey,
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
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Name', border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? 'Name required' : null),
                    const SizedBox(height: 15),
                    TextFormField(
                        controller: _logoCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Acronym', border: OutlineInputBorder()),
                        maxLength: 6),
                    const SizedBox(height: 15),
                    TextFormField(
                        controller: _bioCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true),
                        maxLines: 4),
                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 15),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                                color: Color(0xFF002147),
                                shape: BoxShape.circle),
                            clipBehavior: Clip.antiAlias,
                            child: (_finalProfileUrl != null)
                                ? Image.network(_finalProfileUrl!,
                                    fit: BoxFit.cover)
                                : Center(
                                    child: Text(
                                        _logoCtrl.text.isNotEmpty
                                            ? _logoCtrl.text.substring(0, 1)
                                            : 'U',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text('Profile Photo (Max 50MB)',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                const Text('Recommended: 400x400 px',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 10),
                                _isUploadingProfile
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF002147),
                                            foregroundColor: Colors.white),
                                        onPressed: () => _handleUpload(0),
                                        icon:
                                            const Icon(Icons.upload, size: 18),
                                        label: const Text('Change Photo'))
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
                            border: Border.all(color: Colors.grey.shade300)),
                        clipBehavior: Clip.antiAlias,
                        child: (_finalHeaderUrl != null &&
                                _finalHeaderUrl!.isNotEmpty)
                            ? Image.network(_finalHeaderUrl!,
                                fit: BoxFit.cover,
                                cacheWidth: 800,
                                errorBuilder: (c, e, s) => const Center(
                                    child: Icon(Icons.broken_image)))
                            : const Center(
                                child: Icon(Icons.image,
                                    color: Colors.grey, size: 40))),
                    const SizedBox(height: 10),
                    Center(
                        child: _isUploadingHeader
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF002147),
                                    foregroundColor: Colors.white),
                                onPressed: () => _handleUpload(1),
                                icon: const Icon(Icons.add_photo_alternate,
                                    size: 18),
                                label: const Text('Upload New Banner'))),
                    const SizedBox(height: 30),

                    // --- NEW: Background Image Upload ---
                    const Text('Page Background Image (Max 50MB)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300)),
                        clipBehavior: Clip.antiAlias,
                        child: (_finalBgUrl != null && _finalBgUrl!.isNotEmpty)
                            ? Image.network(_finalBgUrl!,
                                fit: BoxFit.cover,
                                cacheWidth: 800,
                                errorBuilder: (c, e, s) => const Center(
                                    child: Icon(Icons.broken_image)))
                            : const Center(
                                child: Icon(Icons.wallpaper,
                                    color: Colors.grey, size: 40))),
                    const SizedBox(height: 10),
                    Center(
                        child: _isUploadingBg
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF002147),
                                    foregroundColor: Colors.white),
                                onPressed: () => _handleUpload(2),
                                icon: const Icon(Icons.add_photo_alternate,
                                    size: 18),
                                label: const Text('Upload Background'))),
                    const SizedBox(height: 10),
                    const Center(
                        child: Text(
                            'This image will be blurred automatically in the background.',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12))),
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
                onPressed: _isSaving ||
                        _isUploadingProfile ||
                        _isUploadingHeader ||
                        _isUploadingBg
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSaving = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection(widget.targetCollection)
                                .doc(widget.targetId)
                                .update({
                              'name': _nameCtrl.text.trim(),
                              'bio': _bioCtrl.text.trim(),
                              'logo_text': _logoCtrl.text.trim(),
                              'profile_image_url': _finalProfileUrl,
                              'header_image_url': _finalHeaderUrl,
                              'bg_image_url':
                                  _finalBgUrl, // --- NEW: Push to Firestore ---
                            });
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Save Error: $e')));
                            setState(() => _isSaving = false);
                          }
                        }
                      },
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))))
      ],
    );
  }
}
