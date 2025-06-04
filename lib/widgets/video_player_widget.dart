
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
    required this.viewOnly,
  });

  final String videoUrl;
  final Color color;
  final bool viewOnly;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController  videoPlayerController;
  late FlickManager flickManager;
  bool isPlaying = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      autoPlay: false,
      videoPlayerController:
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl),
      
    ));
    isLoading = false;
  }



  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && mounted) {
          flickManager.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager.flickControlManager?.autoResume();
        }
      },
      child: Stack(
        children: [
          isLoading
              ? const Center(
                  child: FlickAutoPlayCircularProgress(),
                )
              : VisibilityDetector(
                key: ObjectKey(flickManager),
                onVisibilityChanged: (visibility){
                              if (visibility.visibleFraction == 0 && this.mounted) {
                                flickManager?.flickControlManager?.pause();//pausing  functionality 
                              }

                            },
                child: FlickVideoPlayer(
                    flickManager: flickManager,
                    flickVideoWithControls: const FlickVideoWithControls(
                      closedCaptionTextStyle: TextStyle(fontSize: 8),
                      controls: FlickPortraitControls(),
                      aspectRatioWhenLoading: 16 / 9,
                    ),
                    
                    flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                      videoFit: BoxFit.contain,
                      controls: FlickLandscapeControls(),
                      
                    ),
                  ),
              ),
        ],
      ),
    );
  }
}