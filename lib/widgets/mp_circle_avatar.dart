import 'dart:io';
import 'package:flutter/material.dart';

Widget avatar(File f, String title, MaterialColor color) {
  return new Material(
    borderRadius: new BorderRadius.circular(20.0),
    elevation: 3.0,
    child:  Container(
             decoration: BoxDecoration(
               shape: BoxShape.circle,
                 boxShadow: [BoxShadow(
                     color: Colors.grey[700],
                     blurRadius: 6.0,
                     spreadRadius: 2.0
                 ),]
             ),
          child: new CircleAvatar(

              child: new Icon(
                Icons.play_arrow,
                color: Colors.grey,

              ),
              backgroundColor: Colors.black,

            ),
        ),
  );
}
