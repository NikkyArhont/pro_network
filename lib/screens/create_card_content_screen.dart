import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../widgets/expiry_date_picker_sheet.dart';

class CreateCardContentScreen extends StatefulWidget {
  final String cardId;
  final String initialType; // 'news' or 'offer'

  const CreateCardContentScreen({
    super.key, 
    required this.cardId, 
    this.initialType = 'news',
  });

  @override
  State<CreateCardContentScreen> createState() => _CreateCardContentScreenState();
}

class _CreateCardContentScreenState extends State<CreateCardContentScreen> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _selectedImage;
  Map<String, dynamic>? _userData;
  bool _isLoadingData = true;
  bool _isPublishing = false;
  DateTime _startsAt = DateTime.now();
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final data = await _userService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpiryDatePickerSheet(
        initialStartDate: _startsAt,
        initialEndDate: _expiresAt ?? DateTime.now().add(const Duration(days: 1)),
        onSave: (start, end) {
          setState(() {
            _startsAt = start;
            _expiresAt = end;
          });
        },
        onReset: () {
          setState(() {
            _expiresAt = null;
          });
        },
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите фото для поста')),
      );
      return;
    }

    setState(() => _isPublishing = true);

    // Determine type: if expiresAt is set, it's an offer, else news.
    // Or we can just use the initialType if the user doesn't change it.
    final type = _expiresAt != null ? 'offer' : 'news';

    final bool success = await _postService.createPost(
      _selectedImage!,
      _textController.text,
      postType: type,
      expiresAt: _expiresAt,
      cardId: widget.cardId,
    );

    if (mounted) {
      setState(() => _isPublishing = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Контент успешно опубликован!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при публикации')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF01191B),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.initialType == 'offer' ? 'Новое предложение' : 'Новый пост визитки',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Image Selection Placeholder
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 266,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334D50),
                          borderRadius: BorderRadius.circular(10),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: kIsWeb 
                                    ? NetworkImage(_selectedImage!.path) 
                                    : FileImage(File(_selectedImage!.path)) as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Container(
                                  width: 77,
                                  height: 77,
                                  decoration: const ShapeDecoration(
                                    color: Color(0xFFFF8E30),
                                    shape: CircleBorder(),
                                  ),
                                  child: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 30),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Author Info Card (Simplified or same as CreatePost)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3135),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: (_userData?['photoUrl']?.isNotEmpty == true)
                                    ? NetworkImage(_userData!['photoUrl'])
                                    : const NetworkImage("https://ui-avatars.com/api/?name=User&size=70"),
                                fit: BoxFit.cover,
                              ),
                              shape: const OvalBorder(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData?['displayName'] ?? 'Загрузка...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.business_center_outlined, color: Color(0xFFC6C6C6), size: 14),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        '${_userData?['jobTitle'] ?? 'Должность'} • ${_userData?['company'] ?? 'Компания'}',
                                        style: const TextStyle(
                                          color: Color(0xFFC6C6C6),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Text Input
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3135),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF557578), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: 5,
                            maxLength: 500,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'О чем вы хотите рассказать в этой визитке?',
                              hintStyle: TextStyle(color: Color(0xFF637B7E)),
                              border: InputBorder.none,
                              counterStyle: TextStyle(color: Color(0xFFC6C6C6)),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Set Expiration Button
                  GestureDetector(
                    onTap: _pickExpiryDate,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF557578),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            _expiresAt == null 
                              ? 'Установить срок действия' 
                              : 'Срок до: ${DateFormat('dd.MM.yyyy').format(_expiresAt!)}',
                            style: const TextStyle(
                              color: Color(0xFF557578),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Publish Button
                  GestureDetector(
                    onTap: _isPublishing ? null : _handlePublish,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isPublishing ? Colors.grey : const Color(0xFF334D50),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF557578)),
                      ),
                      child: Center(
                        child: _isPublishing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Опубликовать',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
