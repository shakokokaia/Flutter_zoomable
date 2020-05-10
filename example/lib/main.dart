import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zoomable/zoomable.dart';

extension on Random {
  String get randomGirl =>
      'https://source.unsplash.com/collection/8909560/${Random().nextInt(20) + 1000}x${Random().nextInt(20) + 1000}';

  String get randomMan =>
      'https://source.unsplash.com/collection/3733842/${Random().nextInt(20) + 1000}x${Random().nextInt(20) + 1000}';
}

void main() => runApp(ZoomableApp());

class ZoomableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ZoomableHome(),
    );
  }
}

class ZoomableHome extends StatefulWidget {
  @override
  _ZoomableHomeState createState() => _ZoomableHomeState();
}

class _ZoomableHomeState extends State<ZoomableHome> {
  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView.builder(itemBuilder: (_, int index) {
            return Container(
              height: 400,
              width: dSize.width,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(.3),
                    offset: Offset(0, 6),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Zoomable(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.network(
                    index % 2 == 0 ? Random().randomGirl : Random().randomMan,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
          _appbar,
        ],
      ),
    );
  }

  Widget get _appbar => ClipRRect(
        child: Container(
          width: double.infinity,
          height: 56 + MediaQuery.of(context).padding.top,
          alignment: Alignment.bottomCenter,
          color: Colors.white70,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Zoomable 🔥',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
}
