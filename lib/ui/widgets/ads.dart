import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:video_player/video_player.dart';

class AdsDialog extends StatefulWidget {
  @override
  String video_url;
  AdsDialog({this.video_url});
  _AdsDialogState createState() => _AdsDialogState();
}

class _AdsDialogState extends State<AdsDialog> {

  int waiting_time = 0;
  VideoPlayerController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _video_init();
  }

  @override
  void dispose(){
    super.dispose();
    _controller.dispose();
  }

  _video_init()async{
    _controller = VideoPlayerController.network(widget.video_url)..initialize().then((_){
      Timer.periodic(Duration(milliseconds: ads_duration_seconds*10), (timer){
        setState(() {
          waiting_time+=ads_duration_seconds*10;
        });
        if(waiting_time == ads_duration_seconds*1000){
          timer.cancel();
        }
      });
      setState(() {
        _controller.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: new Material(
        type: MaterialType.transparency,
        child:Container(
          alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: 30,right: 30,top: 50, bottom: 50
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
//              image: new DecorationImage(image: new AssetImage("assets/images/ads.png"),
//                fit: BoxFit.cover
//              ),
            ),
            child: Stack(
              alignment: Alignment(1, 1),
              children: <Widget>[
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      child: _controller.value.initialized?
                      VideoPlayer(_controller):
                      Center(child: CircularProgressIndicator(),),
                    ),
                  ),
                ),
                _controller.value.initialized?Container(
                  padding: EdgeInsets.only(
                    left: 3,right: 3,
                  ),
                  child: LinearPercentIndicator(
                    lineHeight: 25.0,
                    percent: waiting_time/(ads_duration_seconds*1000),
                    center: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        waiting_time==ads_duration_seconds*1000?
                        Text(
                          "Ad Complete",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "phenomena-regular",
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ):
                        Text(
                          "Ad 1 of 1",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "phenomena-regular",
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        waiting_time==ads_duration_seconds*1000?InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Text(
                            "continue >",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "phenomena-regular",
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ),
                          ),
                        ):Container(),
                      ],
                    ),
                    backgroundColor: Colors.blue[800],
                    progressColor: Colors.blue[300],
                  ),
                ):Container()
              ],
            )
        ),
    ), onWillPop: (){return null;});
  }
}