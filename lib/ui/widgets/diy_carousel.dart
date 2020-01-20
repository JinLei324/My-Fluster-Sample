import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:groomlyfe/models/video.dart';
import 'package:groomlyfe/ui/widgets/ads.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class DiyCarousel extends StatefulWidget {
  @override
  _DiyCarouselState createState() => _DiyCarouselState();
}

class _DiyCarouselState extends State<DiyCarousel> {
  List<Video> diy_videos;

  bool check_video_play = false;

  Video current_video;

  int i = 0;

  double ratio;

  VideoPlayerController _controller;

  _video_init(String video_url) async {
    _controller = VideoPlayerController.network(video_url)
      ..initialize().then((_) {
        setState(() {
          ratio = _controller.value.aspectRatio;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: diy_videos.isEmpty
          ? Container(
              height: (device_height - 160) / 3,
              child: Center(
                child: Text(
                  "DIY",
                  style: TextStyle(color: Colors.grey[300], fontSize: 20),
                ),
              ),
            )
          : CarouselSlider(
              height: (device_height - 160) * 0.35,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: Duration(milliseconds: 5000),
              autoPlayCurve: Curves.linear,
              autoPlayAnimationDuration: Duration(milliseconds: 5000),
              pauseAutoPlayOnTouch: Duration(seconds: 2),
              onPageChanged: (c) {},
              scrollDirection: Axis.horizontal,
              items: diy_videos.map((video) {
                i++;
                return InkWell(
                    onTap: () {
                      if (video.video_category.toUpperCase() != "*ADS") {
                        _video_init(video.video_url);
                        setState(() {
                          check_video_play = true;
                          current_video = video;
                        });
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => AdsDialog(
                                  video_url: video.video_url,
                                ));
                      }
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: (device_height - 150) * 0.35,
                          width: device_width,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Container(
                                margin:
                                    EdgeInsets.only(bottom: 4, right: 4),
                                decoration: BoxDecoration(
                                    border: video.video_category
                                                .toUpperCase() ==
                                            "*ADS"
                                        ? Border.all(
                                            color: Colors.green, width: 4)
                                        : null,
                                    borderRadius: BorderRadius.circular(23),
                                    boxShadow: [
                                      new BoxShadow(
                                          color: Colors.grey,
                                          offset: new Offset(0, 4),
                                          blurRadius: 4)
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: video.image_url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                child: new Builder(
                                  builder: (context) {
                                    String cat_icon_name;
                                    try {
                                      cat_icon_name =
                                          video.video_description;
                                    } catch (e) {}
                                    print(cat_icon_name);
                                    return cat_icon_name == "null"
                                        ? Image.asset(
                                            "assets/category/${video.video_category}.png",
                                          )
                                        : Image.asset(
                                            "assets/category/$cat_icon_name.png",
                                          );
                                  },
                                ),
                                top: -7,
                                right: -11,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(
                              top: 5, bottom: 5, right: 30, left: 30),
                        ),
                        StreamBuilder(
                          stream: FirebaseDatabase.instance
                              .reference()
                              .child("video")
                              .child("${video.key}")
                              .onValue,
                          builder: (context, snap) {
                            bool isStreaming = false;
                            if (snap.hasData &&
                                !snap.hasError &&
                                snap.data.snapshot.value != null) {
                              Map data = snap.data.snapshot.value;
                              print("-=-=-=-=-=-=-");
                              isStreaming = data['isStreaming'];
                              print(data['isStreaming']);
                            }

                            return isStreaming
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Container();
                          },
                        ),
                      ],
                    ));
              }).toList(),
            ),
    );
  }
}
