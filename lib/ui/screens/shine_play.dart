import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:custom_chewie/custom_chewie.dart';
import 'package:groomlyfe/models/video.dart';
import 'package:groomlyfe/models/messages.dart';
import 'package:groomlyfe/ui/widgets/avatar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:groomlyfe/ui/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

import 'package:groomlyfe/util/database.dart';
//////////////////////////////////////////Video play////////////////////////////////////////////////////////////////
class Video_shine_play extends StatefulWidget{
  Video video;

  Video_shine_play(this.video);
  String path;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Video_shine_play_state(video);
  }
}

class Video_shine_play_state extends State<Video_shine_play>{
  Video_shine_play_state(this.video);
  TextEditingController _messageController;
  VideoPlayerController _controller;
  Video video;

  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
//    SystemChrome.setEnabledSystemUIOverlays([]);
    //_controller = VideoPlayerController.asset("videos/sample_video.mp4");
    _messageController = new TextEditingController();
    _video_init(video.video_url);
    super.initState();
  }

  _video_init(String video_url)async{

    _controller = VideoPlayerController.network(video_url)..initialize().then((_){
      setState(() {
       _controller.seekTo(Duration(seconds: int.parse(video.current_time)+3));
       _controller.play();
      });
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
  _refresh()async{
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _refresh();
    // TODO: implement build
    return Scaffold(
        body: Container(color: Colors.black,child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Builder(builder: (context){
              return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: _controller.value.initialized?
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ):
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              );
            }),
            Container(
                margin:EdgeInsets.only(left: 10,top: 30),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                        ),
                        InkWell(
                          child: Avatar(
                              video.user_id==user_id?user_image_url:
                              video.user_image_url,video.user_id, scaffoldKey, context).small_logo_home(),
                          onTap: (){

                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              video.user_id==user_id?
                              "$user_firstname $user_lastname":
                              video.user_name,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,fontFamily: "Nova Round"),),
                            Container(
                              width: device_width*0.6,
                              child: Text("${video.video_title}",style: TextStyle(fontSize: 14, color: Colors.white,fontFamily: "Nova Round"),),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Stack(
                          alignment:Alignment(-0.1, -0.3),
                          children: <Widget>[
                            Container(
                              child: Image.asset("assets/images/shine_video.png",width: 70,height: 70,),
                            ),
                            StreamBuilder(
                              stream: FirebaseDatabase.instance.reference().child("video").child("${video.key}").onValue,
                              builder: (context, snap){
                                DataSnapshot snapshot;
                                if(snap.hasData||snap.data!=null){
                                  snapshot = snap.data.snapshot;
                                }

                                if(snapshot == null){
                                  return Container();
                                }else {
                                  bool isStreaming = false;
                                  isStreaming = snapshot.value["isStreaming"]==null?false:snapshot.value["isStreaming"];
                                  print("${snapshot.value["isStreaming"]}");
                                  return isStreaming?
                                  CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation(Colors.red),
                                  ):Container();
                                }
                              },
                            ),
                          ],
                        ),
                        InkWell(
                          child: Image.asset("assets/images/chat_icon.png",width: 70,height: 70,),
                          onTap: (){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                content:Container(
                                  height: device_height*0.7,
                                  alignment: Alignment.bottomCenter,
                                  child:  SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: StreamBuilder(
                                              stream: FirebaseDatabase.instance
                                                  .reference()
                                                  .child('message')
                                                  .orderByChild('videoKey').equalTo(video.key)//order by creation time.
                                                  .onValue,
                                              builder: (context, snap) {
                                                if (snap.hasData && !snap.hasError && snap.data.snapshot.value!=null) {
                                                  DataSnapshot snapshot = snap.data.snapshot;
                                                  List<ChatMessage> messages=[];

                                                  snapshot.value.forEach((key, value){
                                                    if(value!=null){
                                                      print(value);
                                                      ChatMessage messageItem = ChatMessage(key:"$key", videoKey: "${value['videoKey']}",userid: "${value['userid']}",username:
                                                      "${value['username']}",user_create_at: "${value['user_create_at']}",photoUrl: "${value['photoUrl']}", message: "${value['message']}");
                                                      print(messageItem.message);
                                                      messages.add(messageItem);
                                                    }
                                                  }
                                                  );

                                                  messages.sort((a, b){
                                                    return a.key.toString().compareTo(b.key.toString());
                                                  });
                                                  return snap.data.snapshot.value == null
                                                      ? SizedBox()
                                                      : Column(
                                                      children: messages.map((item){
                                                        return Container(
                                                          padding: EdgeInsets.only(top: 5,bottom: 5),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: item.photoUrl==""?Icon(Icons.person,size: 22,color: Colors.blueGrey,):Image.network("${item.photoUrl}", fit: BoxFit.cover,width: 20,height: 20,),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.all(5),
                                                              ),
                                                              Container(
                                                                width:device_width-160,
                                                                child: Text(
                                                                  "${item.message}",
                                                                  style: TextStyle(
                                                                      color: Colors.white
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList()
                                                  );
                                                } else {
                                                  return   Center(child: Container());
                                                }
                                              },
                                            ),
                                          ),


                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          TextField(
                                            controller: _messageController,
                                            style: TextStyle(
                                                color: Colors.white
                                            ),
                                            decoration: InputDecoration(
                                                icon: Avatar(user_image_url,user_id, scaffoldKey, context).small_logo_message(),
                                                hintText: "Insert message.",
                                                hintStyle: TextStyle(color: Colors.white),
                                                suffixIcon: InkWell(
                                                  child: Icon(Icons.send,color: Colors.white,),
                                                  onTap: (){
                                                    var now = DateTime.now() .toString();
                                                    if(_messageController.text!=""){
                                                      MessageData().addMessageDB(ChatMessage(videoKey:video.key,userid: user_id ,username: "${user_firstname} ${user_lastname}",user_create_at: user_create_at, photoUrl: user_image_url, message: _messageController.text, created_at: now));
                                                      setState(() {
                                                        _messageController.text = "";
                                                      });
                                                    }
                                                  },
                                                )
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset("assets/images/fire_icon@2x.png",width: 27,height: 27,),
                              Text("${video.video_like_count}", style: TextStyle(fontSize: 10,color: Colors.white),),
                              Padding(padding: EdgeInsets.only(top: 5),),
                              Image.asset("assets/images/people_icon@2x.png",width: 27,height: 27,),
                              Text("${video.video_view_count}", style: TextStyle(fontSize: 10,color: Colors.white),),
                              Padding(padding: EdgeInsets.only(top: 5),),
                              Image.asset("assets/images/Group 68.png",width: 27,height: 27,),
                              Text("${video.video_groomlyfe_count}", style: TextStyle(fontSize: 10,color: Colors.white),),
                              Padding(padding: EdgeInsets.only(top: 10),),
                              Container(padding: EdgeInsets.all(0),
                                child: Avatar(user_image_url,user_id, scaffoldKey, context).small_logo_home(),
                              ),
                              Padding(padding: EdgeInsets.all(10),)
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )

            ),
          ],
        ),),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(19),),
            StreamBuilder(
              stream: FirebaseDatabase.instance.reference().child("video").child("${video.key}").onValue,
              builder: (context, snap){
                DataSnapshot snapshot;
                if(snap.hasData||snap.data!=null){
                  snapshot = snap.data.snapshot;
                }

                if(snapshot == null){
                  return Container();
                }else {
                  bool isStreaming = false;
                  isStreaming = snapshot.value["isStreaming"]==null?false:snapshot.value["isStreaming"];
                  print("${snapshot.value["isStreaming"]}");
                  return Container(
                    width: 50,
                    height: device_height,
                    child: SpeedDial(
                      // both default to 16
                      // this is ignored if animatedIcon is non null
                      // child: Icon(Icons.add),
                      visible: true,
                      // If true user is forced to close dial manually
                      // by tapping main button and overlay is not rendered.
                      curve: Curves.bounceIn,
                      closeManually: false,
                      overlayOpacity: 0,
                      onOpen: () => print('OPENING DIAL'),
                      onClose: () => print('DIAL CLOSED'),
                      tooltip: 'Speed Dial',
                      heroTag: 'speed-dial-hero-tag',
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      elevation: 8.0,
                      children: [
                        SpeedDialChild(
                          child: Icon(Icons.ac_unit,color: user_id==video.user_id?(isStreaming?Colors.red:Colors.white):Colors.grey,),
                          backgroundColor: Colors.black.withOpacity(0.2),
                          onTap: () {
                            if(user_id==video.user_id&&!isStreaming){
                              int video_position = _controller.value.position.inSeconds;
                              int video_end = _controller.value.duration.inSeconds;

                              FirebaseDatabase.instance.reference().child("video").child("${video.key}").update(
                                  {
                                    "isStreaming":true,
                                    "current_time":"${video_position}",
                                    "end_time":"${video_end}"
                                  }
                              );
                              Timer.periodic(Duration(milliseconds: 1000), (timer){
                                video_position++;
                                FirebaseDatabase.instance.reference().child("video").child("${video.key}").update(
                                    {
                                      "isStreaming":true,
                                      "current_time":"${video_position}"
                                    }
                                );
                                if(video_position >= (video_end+1)){
                                  timer.cancel();
                                  FirebaseDatabase.instance.reference().child("video").child("${video.key}").update(
                                      {
                                        "isStreaming":false,
                                        "current_time":"0"
                                      }
                                  );
                                }

                              });

                            }
                            if(isStreaming){
                              ToastShow("Shinning...!", context, Colors.red[700]).init();
                            }
                            if(user_id!=video.user_id){
                              ToastShow("Sorry! This isn't your video.", context, Colors.red[700]).init();
                            }
                            print("${_controller.value.position}");
                            print("++++++++++++++++++++++++++++++");
                            print("${_controller.value.duration}");
                          },
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.favorite),
                          backgroundColor: Colors.black.withOpacity(0.2),
                          onTap: () => print('favorite'),
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.thumb_up),
                          backgroundColor: Colors.black.withOpacity(0.2),
                          onTap: () => print('thumb'),
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.check),
                          backgroundColor: Colors.black.withOpacity(0.2),
                          onTap: () => print('check'),
                        ),
                        SpeedDialChild(
                          child: Icon(Icons.share),
                          backgroundColor: Colors.black.withOpacity(0.2),
                          onTap: () => print('share'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

          ],
        )
    );
  }
}