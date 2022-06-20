import 'dart:convert';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shadi/audioPlayerPage/albumart.dart';
import 'package:shadi/audioPlayerPage/colors.dart';
import 'package:shadi/audioPlayerPage/myaudio.dart';
import 'package:shadi/zaid/player_buttons.dart';

class ResultPage extends StatefulWidget {
  static final id = "ResultPage";

  const ResultPage({Key key}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double valueHolder = 20;
  AudioPlayer _audioPlayer = AudioPlayer();
  double sliderValue = 2;
  String lyrics = "";
  Stream<DurationState> _durationState;

  // Map audioData = {
  //   'image':
  //       'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
  //   'url':
  //       'https://thegrowingdeveloper.org/files/audios/quiet-time.mp3?b4869097e4'
  // };

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            progress: progress,
            buffered: buffered,
            total: total,
            onSeek: (duration) {
              _audioPlayer.seek(duration);
            },
            onDragUpdate: (details) {
              debugPrint('${details.timeStamp}, ${details.localPosition}');
            },
            barHeight: 5,
            thumbGlowRadius: 25,
            baseBarColor: Color(0xff6f3d2e).withOpacity(0.3),
            progressBarColor: Color(0xff6f3d2e),
            bufferedBarColor: Color(0xff6f3d2e),
            thumbColor: Colors.black54,
            thumbGlowColor: Color(0xff6f3d2e).withOpacity(0.3),
            barCapShape: BarCapShape.round,
            thumbRadius: 8,
            thumbCanPaintOutsideBar: false,
            timeLabelLocation: TimeLabelLocation.below,
            timeLabelType: TimeLabelType.totalTime,
            timeLabelTextStyle: TextStyle(color: Colors.black),
            timeLabelPadding: 5,
          ),
        );
      },
    );
  }

  Future<void> _init() async {
    try {
      await _audioPlayer;
    } catch (e) {
      debugPrint('An error occured $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _audioPlayer.positionStream,
        _audioPlayer.playbackEventStream,
        (position, playbackEvent) => DurationState(
              progress: position,
              buffered: playbackEvent.bufferedPosition,
              total: playbackEvent.duration,
            ));
    _init();
    // Hardcoded audio sources
    // TODO: Get sources with a network call, or at least move to a separated file.
    _playlist = ConcatenatingAudioSource(
      children: [
        AudioSource.uri(
          Uri.parse(
              "https://archive.org/download/IGM-V7/IGM%20-%20Vol.%207/25%20Diablo%20-%20Tristram%20%28Blizzard%29.mp3"),
          tag: AudioMetadata(
            title: "Tristram",
            artwork:
                "https://st4.depositphotos.com/39198686/40505/v/380/depositphotos_405055682-stock-illustration-neon-icon-pink-musical-note.jpg?forcejpeg=true",
          ),
        ),
        AudioSource.uri(
          Uri.parse(
              "https://archive.org/download/igm-v8_202101/IGM%20-%20Vol.%208/15%20Pokemon%20Red%20-%20Cerulean%20City%20%28Game%20Freak%29.mp3"),
          tag: AudioMetadata(
            title: "Cerulean City",
            artwork:
                "https://st4.depositphotos.com/39198686/40505/v/380/depositphotos_405055682-stock-illustration-neon-icon-pink-musical-note.jpg?forcejpeg=true",
          ),
        ),
        AudioSource.uri(
          Uri.parse(
              "https://scummbar.com/mi2/MI1-CD/01%20-%20Opening%20Themes%20-%20Introduction.mp3"),
          tag: AudioMetadata(
            title: "The secret of Monkey Island - Introduction",
            artwork:
                "https://st4.depositphotos.com/39198686/40505/v/380/depositphotos_405055682-stock-illustration-neon-icon-pink-musical-note.jpg?forcejpeg=true",
          ),
        ),
      ],
    );
    _audioPlayer.setAudioSource(_playlist);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  ConcatenatingAudioSource _playlist;

  void addSong() {
    final songNumber = _playlist.length + 1;
    // const prefix =
    //     'https://thegrowingdeveloper.org/files/audios/quiet-time.mp3?b4869097e4';
    // final song = Uri.parse('$prefix/SoundHelix-Song-$songNumber.mp3');
    _playlist.add(AudioSource.uri(
      Uri.parse(
          "https://thegrowingdeveloper.org/files/audios/quiet-time.mp3?b4869097e4"),
      tag: AudioMetadata(
        title: "$songNumber",
        artwork:
            "https://st4.depositphotos.com/39198686/40505/v/380/depositphotos_405055682-stock-illustration-neon-icon-pink-musical-note.jpg?forcejpeg=true",
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (_) => MyAudio(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Song'),
          backgroundColor: Color(0xff550062),
          actions: [
            IconButton(
                icon: Icon(Icons.queue_music_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => Playlist(_audioPlayer)),
                  );
                })
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [const Color(0xff550062), const Color(0xffef007e)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  stops: [0.5, 1],
                  tileMode: TileMode.mirror)),
          child: ListView(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 25, top: 20),
                  height: height / 2.5,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return AlbumArt();
                    },
                    itemCount: 1,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Text(
                  'Evantualy',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: darkPrimaryColor),
                ),
                Text(
                  'Tame Impala',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: darkPrimaryColor),
                ),
                SizedBox(
                  height: 45,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.playlist_add_rounded,
                            size: 35,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            addSong();
                          }),
                      Text(
                        'Add to playlist',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
                // Column(
                //   children: [
                //     SliderTheme(
                //       data: SliderThemeData(
                //           trackHeight: 5,
                //           thumbShape:
                //               RoundSliderThumbShape(enabledThumbRadius: 5)),
                //       child: Consumer<MyAudio>(
                //         builder: (_, myAudioModel, child) => Slider(
                //           value: myAudioModel.position == null
                //               ? 0
                //               : myAudioModel.position.inMilliseconds.toDouble(),
                //           activeColor: darkPrimaryColor,
                //           inactiveColor: darkPrimaryColor.withOpacity(0.3),
                //           onChanged: (value) {
                //             myAudioModel.seekAudio(
                //                 Duration(milliseconds: value.toInt()));
                //           },
                //           min: 0,
                //           max: myAudioModel.totalDuration == null
                //               ? 20
                //               : myAudioModel.totalDuration.inMilliseconds
                //                   .toDouble(),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: 20,
                ),
                _progressBar(),
                SizedBox(
                  height: 20,
                ),
                PlayerButtons(_audioPlayer),
                SizedBox(
                  height: 100,
                ),
                FlatButton(
                    onPressed: () async {
                      final response = await http
                          .get(Uri.parse("http://192.168.64.14:7890/lyrics"));

                      final decoded =
                          json.decode(response.body) as Map<String, dynamic>;
                      setState(() {
                        lyrics = decoded['response'];
                        print(lyrics);
                      });
                    },
                    child: Text("press")),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist(this._audioPlayer, {Key key}) : super(key: key);

  final AudioPlayer _audioPlayer;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
        backgroundColor: Color(0xff550062),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0xff550062), const Color(0xffef007e)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    stops: [0.5, 1],
                    tileMode: TileMode.mirror)),
            child: StreamBuilder<SequenceState>(
              stream: _audioPlayer.sequenceStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final sequence = state?.sequence ?? [];
                return ListView(
                  children: [
                    for (var i = 0; i < sequence.length; i++)
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            selected: i == state.currentIndex,
                            leading: Image.network(sequence[i].tag.artwork),
                            title: Text(
                              sequence[i].tag.title,
                              // style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _audioPlayer.seek(Duration.zero, index: i);
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.black,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AudioMetadata {
  /// The name of the song/show/recording.
  final String title;

  /// URL to an image representing this audio source.
  final String artwork;

  AudioMetadata({this.title, this.artwork});
}

class DurationState {
  const DurationState({this.progress, this.buffered, this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
