import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groomlyfe/util/video_picker_handler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';


class CustomVideoPickerDialog extends StatelessWidget {
  VideoPickerHandler _listener;
  AnimationController _controller;
  BuildContext context;
  CustomVideoPickerDialog(this._listener, this._controller);
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => new SlideTransition(
        position: _drawerDetailsPosition,
        child: new FadeTransition(
          opacity: new ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    _controller.dispose();
  }

  startTime() async {
    var _duration = new Duration(milliseconds: 200);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _controller.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new GestureDetector(
      onTap:(){
        dismissDialog();
    },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: new Center(
              child: GestureDetector(
                onTap: (){
                  return null;
                },
                child: Container(
                  width: 100,
                  height: 160,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height-220,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                _listener.openCamera();
                              },
                              highlightColor: Colors.grey,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text("Camera",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.grey,
                              height: 1,
                            ),
                            InkWell(
                              onTap: (){
                                _listener.openGallery();
                              },
                              highlightColor: Colors.grey,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text("Gallery",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                dismissDialog();
                              },
                              highlightColor: Colors.grey,
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 3,
                                    bottom: 3
                                ),
                                color: Colors.red,
                                child: Text("Cancel",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipPath(
                        clipper: TriangleClipper(),
                        child: Container(
                          width: 83,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.white,
                                  width: 1
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          )),
    );
  }

}
