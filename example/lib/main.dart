library zoomable.example;

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

extension on BoxDecoration {
  BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo[50],
            offset: Offset(0, 0),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      );
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView.builder(itemBuilder: (_, __) => ListItem()),
          ZoomableAppBar(),
        ],
      ),
    );
  }
}

class ZoomableAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
}

class ListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imgUrl =
        Random().nextInt(2) == 0 ? Random().randomGirl : Random().randomMan;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(30),
      decoration: BoxDecoration().cardDecoration,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Zoomable(
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                'Zoomable Kurdadze',
                style: textTheme.subtitle1.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                '22m ago',
                style: textTheme.caption,
              ),
              trailing: Icon(
                Random().nextInt(2) == 0
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
