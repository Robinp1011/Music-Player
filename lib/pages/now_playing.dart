import 'dart:async';
import 'dart:ui';
import 'package:musicplayer/data/song_data.dart';
import 'package:musicplayer/widgets/mp_album_ui.dart';
import 'package:musicplayer/widgets/mp_blur_filter.dart';
import 'package:musicplayer/widgets/mp_blur_widget.dart';
import 'package:musicplayer/widgets/mp_control_button.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';

enum PlayerState { stopped, playing, paused }

class NowPlaying extends StatefulWidget {
  final Song _song;
  final SongData songData;
  final bool nowPlayTap;
  NowPlaying(this.songData, this._song, {this.nowPlayTap});

  @override
  _NowPlayingState createState() => new _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  MusicFinder audioPlayer;
  Duration duration;
  Duration position;
  PlayerState playerState;
  Song song;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  @override
  initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
    play(widget.songData.nextSong);
  }

  initPlayer() async {
    if (audioPlayer == null) {
      audioPlayer = widget.songData.audioPlayer;
    }
    setState(() {
      song = widget._song;
      if (widget.nowPlayTap == null || widget.nowPlayTap == false) {
        if (playerState != PlayerState.stopped) {
          stop();
        }
      }
      play(song);
      //  else {
      //   widget._song;
      //   playerState = PlayerState.playing;
      // }
    });
    audioPlayer.setDurationHandler((d) => setState(() {
          duration = d;
        }));

    audioPlayer.setPositionHandler((p) => setState(() {
          position = p;
        }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play(Song s) async {
    if (s != null) {
      final result = await audioPlayer.play(s.uri, isLocal: true);
      if (result == 1)
        setState(() {
          playerState = PlayerState.playing;
          song = s;
        });
    }
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  Future next(SongData s) async {
    stop();
    setState(() {
      play(s.nextSong);
    });
  }

  Future prev(SongData s) async {
    stop();
    play(s.prevSong);
  }

  Future mute(bool muted) async {
    final result = await audioPlayer.mute(muted);
    if (result == 1)
      setState(() {
        isMuted = muted;
      });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildPlayer() => new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          new Column(
            children: <Widget>[
              new Text(
                song.title,
                style: new TextStyle(color: Colors.grey, fontSize: 24),
              ),
              new Text(
                song.artist,
                style: new TextStyle(color: Colors.grey,),
              ),
              new SizedBox(
                height: 4,
              ),

            ],
          ),

          new SizedBox(
            height: MediaQuery.of(context).size.height/28,
          ),
          duration == null
              ? new Container()
              : new Slider(
              activeColor: Colors.orange,
              inactiveColor: Colors.black,

              value: position?.inMilliseconds?.toDouble() ?? 0,


              onChanged: (double value) =>
                  audioPlayer.seek((value / 1000).roundToDouble()),
              min: 0.0,
              max: duration.inMilliseconds.toDouble()),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new Text(
                position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : duration != null ? durationText : '',
                // ignore: conflicting_dart_import
                style: new TextStyle(fontSize: 16.0))
          ]),



          new SizedBox(
            height: MediaQuery.of(context).size.height/30,
          ),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.black87,

                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Colors.grey[700],
                        blurRadius: 6.0,
                        spreadRadius: 2.0
                    ),]
                ) ,

                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: new IconButton(icon:Icon(Icons.skip_previous, color: Colors.grey,),
                  onPressed: ()
                    {
                      prev(widget.songData);
                    },
                  ),
                )
            ),

            new SizedBox(
              width: 40,
            ),

            Container(
              decoration: BoxDecoration(
                  color: isPlaying? Colors.orange:Colors.black87,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.grey[700],
                      blurRadius: 6.0,
                      spreadRadius: 2.0
                  ),]
              ) ,


              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: new IconButton(icon:isPlaying ? Icon(Icons.pause, color: Colors.grey,): Icon(Icons.play_arrow, color: Colors.grey,),
                    onPressed: ()
                  {
                    isPlaying ?  pause() :  play(widget._song);
                  },
                    ),
              ),
            ),

            new SizedBox(
              width: 40,
            ),

            Container(
                decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,

                    boxShadow: [BoxShadow(
                      color: Colors.grey[700],
                        blurRadius: 6.0,
                        spreadRadius: 2.0
                    ),]
                ) ,

                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: new IconButton(icon:Icon(Icons.skip_next, color: Colors.grey,),
                  onPressed: ()
                    {
                      next(widget.songData);
                    },
                  ),
                )),
          ]),


        ]));

    var playerUI = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [



          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Container(
                decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Colors.grey[700],
                        blurRadius: 6.0,
                        spreadRadius: 2.0
                    ),]

                ) ,

                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              new SizedBox(
                width: MediaQuery.of(context).size.width/6,
              ),
              new Text("PLAYING  NOW", style: new TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),),

              new SizedBox(
                width: MediaQuery.of(context).size.width/6,
              ),

              Container(
                decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Colors.grey[700],
                        blurRadius: 6.0,
                        spreadRadius: 2.0
                    ),]

                ) ,

                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: IconButton(
                    icon: isMuted
                        ? new Icon(
                      Icons.headset,
                      color: Colors.grey,
                    )
                        : new Icon(Icons.headset_off,
                        color: Colors.grey),
                    onPressed: ()
                    {
                      mute(!isMuted);
                    },
                  ),
                ),
              ),
            ],
          ),

          new SizedBox(
            height: MediaQuery.of(context).size.height/30,
          ),
          new AlbumUI(song, duration, position),
          new Material(
            child: _buildPlayer(),
            color: Colors.transparent,
          ),
        ]);

    return new Scaffold(

      body: new Container(
        color: Colors.black87,
        child: new Stack(
          fit: StackFit.expand,
          children: <Widget>[blurWidget(song), playerUI],
        ),
      ),
    );
  }
}
