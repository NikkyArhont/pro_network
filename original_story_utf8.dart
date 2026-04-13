import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  XFile? _capturedFile;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _onNewCameraSelected(_cameras![_selectedCameraIndex]);
      }
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      print('Error initializing camera controller: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    setState(() {
      _isCameraReady = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });
    
    _onNewCameraSelected(_cameras![_selectedCameraIndex]);
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedFile = photo;
      });
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _capturedFile = image;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Stack(
        children: [
          // Top Status Bar Area
          _buildTopBar(),

          // Camera View / Preview Area
          _buildPreviewArea(),

          // Bottom Controls
          if (_capturedFile == null) _buildCameraControls() else _buildActionControls(),

          // Bottom Indicator
          _buildBottomIndicator(),
          
          // Back Button
          Positioned(
            left: 20,
            top: 70,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '9:41',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Opacity(
                  opacity: 0.35,
                  child: Container(
                    width: 25,
                    height: 13,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  width: 21,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Positioned(
      left: 10,
      top: 71,
      right: 10,
      bottom: 141, // Space for bottom controls
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: _capturedFile != null
            ? _buildCapturedImage()
            : _buildCameraPreview(),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF8E30)),
      );
    }
    
    return CameraPreview(_controller!);
  }

  Widget _buildCapturedImage() {
    return kIsWeb
        ? Image.network(_capturedFile!.path, fit: BoxFit.cover)
        : Image.file(File(_capturedFile!.path), fit: BoxFit.cover);
  }

  Widget _buildCameraControls() {
    return Stack(
      children: [
        // Gallery Button
        Positioned(
          left: 30,
          top: 685,
          child: GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                image: _capturedFile != null ? DecorationImage(
                  image: kIsWeb 
                      ? NetworkImage(_capturedFile!.path) 
                      : FileImage(File(_capturedFile!.path)) as ImageProvider,
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: _capturedFile == null 
                ? const Icon(Icons.photo_library, color: Colors.black, size: 20)
                : null,
            ),
          ),
        ),
        
        // Capture Button
        Positioned(
          left: MediaQuery.of(context).size.width / 2 - 26,
          top: 674,
          child: GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 41,
                  height: 41,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Switch Camera Button
        Positioned(
          right: 30,
          top: 685,
          child: GestureDetector(
            onTap: _switchCamera,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 20),
            ),
          ),
        ),

        // Photo/Video Toggles
        Positioned(
          left: 0,
          right: 0,
          top: 751,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggle('╨д╨╛╤В╨╛', isActive: true),
              const SizedBox(width: 15),
              _buildToggle('╨Т╨╕╨┤╨╡╨╛', isActive: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Delete/Recap Button
          _buildActionButton(
            '╨г╨┤╨░╨╗╨╕╤В╤М', 
            color: Colors.redAccent, 
            icon: Icons.delete_outline,
            onTap: () {
              setState(() {
                _capturedFile = null;
              });
            }
          ),
          // Publish Button
          _buildActionButton(
            '╨Ю╨┐╤Г╨▒╨╗╨╕╨║╨╛╨▓╨░╤В╤М', 
            color: const Color(0xFFFF8E30), 
            icon: Icons.send,
            onTap: () {
              // TODO: Implement Story upload logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('╨Ш╤Б╤В╨╛╤А╨╕╤П ╨╛╨┐╤Г╨▒╨╗╨╕╨║╨╛╨▓╨░╨╜╨░!'))
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, {required Color color, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, {bool isActive = false}) {
    return Container(
      width: 100,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF334D50) : Colors.transparent,
        border: Border.all(
          color: const Color(0xFF557578),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF557578),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: Center(
        child: Container(
          width: 139,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
