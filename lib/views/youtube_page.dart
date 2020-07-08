import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePage extends StatefulWidget {
  final String ytKey;
  YoutubePage({this.ytKey});
  @override
  _YoutubePageState createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.ytKey,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    )..addListener(listener);
    _playerState = PlayerState.unknown;
    _videoMetaData = const YoutubeMetaData();
  }

  void listener() {
    if (mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yt Player'),
        backgroundColor: Color(0xff0e0e0e),
        centerTitle: true,
      ),
      backgroundColor: Color(0xff0e0e0e),
      body: Center(
        child: YoutubePlayer(
          progressColors: ProgressBarColors(
            handleColor: Colors.pinkAccent,
            backgroundColor: Colors.pinkAccent,
            bufferedColor: Colors.pinkAccent,
          ),
          controller: _controller,
          liveUIColor: Colors.amber,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
