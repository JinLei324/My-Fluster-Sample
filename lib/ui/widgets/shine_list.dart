import 'package:flutter/material.dart';
import 'package:groomlyfe/models/video.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:groomlyfe/ui/screens/shine_play.dart';

class MyShiningList extends StatefulWidget {

  @override
  _MyShiningListState createState() => new _MyShiningListState();
}

class _MyShiningListState extends State<MyShiningList> {

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child("video").orderByChild("isStreaming").equalTo(true).onValue,
        builder: (context, snap){
          Widget widget = Center(
            child: Text("Empty"),
          );
          if(snap.hasData&&!snap.hasError&&snap.data.snapshot.value!=null){
            Map data = snap.data.snapshot.value;
            List<Video> streaming_videos = [];
            data.forEach((key, values){
              Video video = Video(key:key,ID: "${values['ID']}",image_url: "${values['image_url']}",video_url: "${values['video_url']}",video_category: "${values['video_category']}",
                  user_id: "${values['user_id']}",user_email: "${values['user_id']}",user_image_url: "${values['user_image_url']}",user_name: "${values['user_name']}",user_create_at: "${values['user_create_at']}",
                  video_description: "${values['video_description']}", video_tag: "${values['video_tag']}", video_title: "${values['video_title']}",video_view_count: values['video_view_count'],
                  video_like_count: values['video_like_count'],video_groomlyfe_count: values['video_groomlyfe_count'],isStreaming: values['isStreaming'], current_time: values['current_time'],
                  end_time: values['end_time']
              );
              streaming_videos.add(video);
            });
            print("++++");
            print(streaming_videos.length);
            widget = ListView(
              children: streaming_videos.map((video){
                return _streaming_video(video);
              }).toList()
            );
          }
          return widget;
        },
      )
    );
  }

  Widget _streaming_video(Video video){
    int current_position_of_video = int.parse(video.current_time);
    int end_position_of_video = int.parse(video.end_time);
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>Video_shine_play(video)
                  ));
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: video.image_url),
                  ),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width-200,
                padding: EdgeInsets.only(left: 10),
                child: Text("${video.video_title}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.thumb_up, color: Colors.black,),
                        SizedBox(
                          width: 10,
                        ),
                        Text("${video.video_like_count}", style: TextStyle(fontSize: 10,color: Colors.black),),

                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.video_label, color: Colors.black,),
                        SizedBox(
                          width: 10,
                        ),
                        Text("${video.video_view_count}", style: TextStyle(fontSize: 10,color: Colors.black),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.thumb_down, color: Colors.black,),
                        SizedBox(
                          width: 10,
                        ),
                        Text("${video.video_groomlyfe_count}", style: TextStyle(fontSize: 10,color: Colors.black),),
                      ],
                    ),
                  ],
                ),
              ),
              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width-200,
                lineHeight: 12.0,
                center: Text(
                  "${constructTime(current_position_of_video)}/${constructTime(end_position_of_video)}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:FontWeight.bold
                  ),
                ),
                percent: current_position_of_video/end_position_of_video,
                backgroundColor: Colors.grey,
                progressColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String constructTime(int seconds) {
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(minute) + ":" + formatTime(second);
  }

  // Digital formatting, converting 0-9 time to 00-09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }
}



