import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadi/audioPlayerPage/colors.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this._audioPlayer, {Key key}) : super(key: key);

  final AudioPlayer _audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width - 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black26,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        StreamBuilder<bool>(
                          stream: _audioPlayer.shuffleModeEnabledStream,
                          builder: (context, snapshot) {
                            return _shuffleButton(
                                context, snapshot.data ?? false);
                          },
                        ),
                        // Previous
                        StreamBuilder<SequenceState>(
                          stream: _audioPlayer.sequenceStateStream,
                          builder: (_, __) {
                            return _previousButton();
                          },
                        ),
                        // Play/pause/restart
                        StreamBuilder<PlayerState>(
                          stream: _audioPlayer.playerStateStream,
                          builder: (_, snapshot) {
                            final playerState = snapshot.data;
                            return _playPauseButton(playerState);
                          },
                        ),
                        // Next
                        StreamBuilder<SequenceState>(
                          stream: _audioPlayer.sequenceStateStream,
                          builder: (_, __) {
                            return _nextButton();
                          },
                        ),
                        // Repeat
                        StreamBuilder<LoopMode>(
                          stream: _audioPlayer.loopModeStream,
                          builder: (context, snapshot) {
                            return _repeatButton(
                                context, snapshot.data ?? LoopMode.off);
                          },
                        ),
                      ],
                    )))));
  }

  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState?.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (_audioPlayer.playing != true) {
      return Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Stack(children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Color(0xff550062),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ]),
              ),
            ),
            Center(
                child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: primaryColor, shape: BoxShape.circle),
                    child: Center(
                        child: IconButton(
                      icon: Icon(Icons.play_arrow),
                      iconSize: 64.0,
                      onPressed: _audioPlayer.play,
                    ))))
          ]));
    } else if (processingState != ProcessingState.completed) {
      return Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Stack(children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Color(0xff550062),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ]),
              ),
            ),
            Center(
                child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: primaryColor, shape: BoxShape.circle),
                    child: Center(
                        child: IconButton(
                      icon: Icon(Icons.pause),
                      iconSize: 64.0,
                      onPressed: _audioPlayer.pause,
                    ))))
          ]));
    } else {
      return Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Stack(children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Color(0xff550062),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ]),
              ),
            ),
            Center(
                child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: primaryColor, shape: BoxShape.circle),
                    child: Center(
                        child: IconButton(
                      icon: Icon(Icons.replay),
                      iconSize: 64.0,
                      onPressed: () => _audioPlayer.seek(Duration.zero,
                          index: _audioPlayer.effectiveIndices.first),
                    ))))
          ]));
    }
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return Controls(
      icon: IconButton(
        iconSize: 25,
        color: darkPrimaryColor,
        icon: isEnabled
            ? Icon(Icons.shuffle, color: Theme.of(context).accentColor)
            : Icon(Icons.shuffle),
        onPressed: () async {
          final enable = !isEnabled;
          if (enable) {
            await _audioPlayer.shuffle();
          }
          await _audioPlayer.setShuffleModeEnabled(enable);
        },
      ),
    );
  }

  Widget _previousButton() {
    return Controls(
      icon: IconButton(
        iconSize: 25,
        color: darkPrimaryColor,
        icon: Icon(Icons.skip_previous),
        onPressed:
            _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
      ),
    );
  }

  Widget _nextButton() {
    return Controls(
      icon: IconButton(
        iconSize: 25,
        color: darkPrimaryColor,
        icon: Icon(Icons.skip_next),
        onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
      ),
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat),
      Icon(Icons.repeat, color: Theme.of(context).accentColor),
      Icon(Icons.repeat_one, color: Theme.of(context).accentColor),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return Controls(
      icon: IconButton(
        iconSize: 25,
        color: darkPrimaryColor,
        icon: icons[index],
        onPressed: () {
          _audioPlayer.setLoopMode(cycleModes[
              (cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
        },
      ),
    );
  }
}

class Controls extends StatelessWidget {
  final IconButton icon;

  const Controls({Key key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xff550062),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: primaryColor, shape: BoxShape.circle),
              child: Center(
                child: icon,
                // size: 30,
                // color: darkPrimaryColor,
                // )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
