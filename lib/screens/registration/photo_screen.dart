import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/screens/registration/agreements_screen.dart';

class PhotoScreen extends StatefulWidget {
  final Map<String, String> profileData;
  const PhotoScreen({super.key, required this.profileData});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  String? _selectedPhotoPath;
  final ImagePicker _picker = ImagePicker();

  void _next({bool skip = false}) {
    final updatedData = Map<String, String>.from(widget.profileData)
      ..['photoUrl'] = skip ? '' : (_selectedPhotoPath ?? '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgreementsScreen(profileData: updatedData),
      ),
    );
  }

  Future<void> _onAddPhotoTap() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedPhotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка выбора фото')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 375,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 59),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3135),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF557578),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Expanded(flex: 2, child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '3/5',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Добавьте фото профиля',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Central Avatar Block
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0C3135),
                          shape: BoxShape.circle,
                        ),
                        child: _selectedPhotoPath != null
                          ? (kIsWeb 
                              ? Image.network(_selectedPhotoPath!, fit: BoxFit.cover) 
                              : Image.file(File(_selectedPhotoPath!), fit: BoxFit.cover))
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF637B7E),
                            ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _onAddPhotoTap,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE86B00),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF01191B), width: 4),
                            ),
                            child: Icon(
                              _selectedPhotoPath != null ? Icons.edit : Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Buttons
                GestureDetector(
                  onTap: () => _next(skip: false),
                  child: Container(
                    height: 35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334D50),
                      border: Border.all(color: const Color(0xFF557578), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Далее',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _next(skip: true),
                  child: Container(
                    height: 35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFF557578), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Пропустить',
                      style: TextStyle(
                        color: Color(0xFF637B7E), 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

