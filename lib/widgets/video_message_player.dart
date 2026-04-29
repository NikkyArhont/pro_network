import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMessagePlayer extends StatefulWidget {
  final String videoUrl;
  final bool isMe;

  const VideoMessagePlayer({super.key, required this.videoUrl, required this.isMe});

  @override
  State<VideoMessagePlayer> createState() => _VideoMessagePlayerState();
}

class _VideoMessagePlayerState extends State<VideoMessagePlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
      
    _controller.addListener(() {
      if (mounted && _controller.value.position == _controller.value.duration) {
         setState(() {}); // Re-render to show play button when finished
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        if (_controller.value.position == _controller.value.duration) {
          _controller.seekTo(Duration.zero);
        }
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(
        width: 150,
        height: 150,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30), strokeWidth: 2)),
      );
    }

    final aspectRatio = _controller.value.aspectRatio;
    
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 220,
                maxHeight: 300,
              ),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          if (!_controller.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
            ),
        ],
      ),
    );
  }
}
