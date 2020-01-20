import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:groomlyfe/global/data.dart';
import 'dart:math';

class YouTubeView extends StatefulWidget {

  @override
  _YouTubeViewState createState() => _YouTubeViewState();
}

class _YouTubeViewState extends State<YouTubeView> {
  static String key = "AIzaSyDwv59d_dSyqyuqtMUoDIf4LJBg43JijVU";// ** ENTER YOUTUBE API KEY HERE **

  static List<String> query_list = [
    "hair cutting",
    "hair cutting men",
    "haircut tutorial for beginners",
    "hairstyles",
    "short hairstyles men",
    "haircut for men",
    "haircut for men tutorial",
    "haircut tutorial",
    "hair tutorial",
    "hair tutorial braid",
    "hair cut style of boys",
    "haircut",
    "asmr haircut men",
    "asmr haircut roleplay",
    "asmr haircut barber",
    "asmr haircut fast",
    "asmr haircut male",
    "Haircut and Style"
  ];
  YoutubeAPI ytApi = new YoutubeAPI(key,maxResults: 50);
  List<YT_API> ytResult = [];

  callAPI() async {
    String query = query_list[Random().nextInt(query_list.length)];
//  String query = "";
    List<YT_API> ytResultGetValues = [];
    ytResultGetValues = await ytApi.search("$query");

    List<int> random_index = [];
    while(random_index.length<10){
      bool random_check = true;

      int random = Random().nextInt(50);
      if(random_index.isNotEmpty){
        for(int item in random_index){
          if(item == random){
            random_check = false;
            break;
          }
        }
      }
      if(random_check){
        random_index.add(random);
      }
    }

    ytResult = [];
    for(int item in random_index){
      ytResult.add(ytResultGetValues[item]);
    }
    setState(() {
      print('UI Updated');
    });
  }
  @override
  void initState() {
    callAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        height: device_height-50,
        child:
        ytResult.isEmpty?
        Center(
          child: CircularProgressIndicator(),
        ):
        SingleChildScrollView(
          child: Column(
            children: ytResult.map((item){

              return Padding(
                padding: EdgeInsets.all(2),
                child: YoutubePlayer(
                  context: context,
                  source: "${item.id}",
                  autoPlay: false,
                  quality: YoutubeQuality.HD,
                  aspectRatio: 16 / 9,
                ),
              );
            }).toList(),
          ),
        ),
      )
    );
  }
}