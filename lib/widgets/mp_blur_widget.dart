import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';

Widget blurWidget(Song song) {
  var f =
      song.albumArt == null ? null : new File.fromUri(Uri.parse(song.albumArt));
  return new Hero(
    tag: song.artist,
    child: new Container(

       color: Colors.black54,
      child:Column(
        children: <Widget>[

        ],
      )
    ),
  );
}
