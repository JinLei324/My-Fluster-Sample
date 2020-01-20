import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:groomlyfe/models/user.dart';
import 'package:groomlyfe/models/state.dart';
import 'package:groomlyfe/models/video.dart';
import 'package:groomlyfe/models/messages.dart';
import 'package:groomlyfe/util/state_widget.dart';
import 'package:groomlyfe/ui/screens/sign_in.dart';
import 'package:groomlyfe/util/database.dart';
import 'package:groomlyfe/util/video_picker_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:groomlyfe/util/get_thumbnails.dart';
import 'package:groomlyfe/util/storage.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:groomlyfe/ui/screens/video_play.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_chewie/custom_chewie.dart';
import 'package:groomlyfe/ui/widgets/avatar.dart';
import 'package:groomlyfe/ui/widgets/toast.dart';
import 'package:groomlyfe/models/categories.dart';
import 'package:groomlyfe/ui/widgets/video_upload_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:groomlyfe/ui/widgets/youtube_play.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:groomlyfe/ui/widgets/ads.dart';
import 'package:groomlyfe/ui/widgets/shining.dart';
import 'package:groomlyfe/ui/widgets/shine_list.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, VideoPickerListner {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  TextEditingController _search_controller = TextEditingController();
  TextEditingController _search_members_controller = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  String query = "";
  List<Map<String, dynamic>> categories_data = [
    {"name": "Groomlyfe", "select_check": false},
    {"name": "Live", "select_check": false},
    {"name": "Cook", "select_check": false},
    {"name": "Art", "select_check": false},
    {"name": "History", "select_check": false},
    {"name": "Fasion", "select_check": false},
    {"name": "Social", "select_check": false},
    {"name": "Sport", "select_check": false},
  ];

  var scaffoldKey = GlobalKey<ScaffoldState>();
  StateModel appState;
  bool isLoading = true;
  bool isUploading = false;
  bool check_video_play = false;
  bool check_enable_video = false;
  bool check_nbx_page_loaded = false;
  bool check_ghost_chat = true;

  double video_click_opacity = 1;

  int i = 0;
  double ratio;

  AnimationController _animationController;
  VideoPlayerController _controller;
  VideoPickerHandler videoPicker;

  List<String> messages = [];
  List<Video> searchVideos;
  List<Video> diy_videos;
  List<Video> hair_videos;
  List<Video> random_videos;
  List<Video> ads_videos = [];

  String title = "VENUE";
  Video current_video;

  List<User> chatUsers = [];
  List<User> chatSearchUsers = [];
  List<bool> selectedUserCheck = [];

  //animation glacad nav change
  bool _venue_visible = false;

  @override
  void initState() {
//    videos_splite = [];
    categories = [];

    for (var item in categories_data) {
      categories.add(Categories.fromJson(item));
    }
    print(categories[0].select_check);

    messages = [];
    isLoading = true;
    isUploading = false;

    user_videos = [];
    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    videoPicker = new VideoPickerHandler(this, _animationController);
    videoPicker.init();
    // TODO: implement initState

    super.initState();
  }

  Future<void> _initVideoData() async {
    List<Video> check_video = user_videos;
    print("+++============+++++++++++++++++++++++++++++$check_video");
    await VideoData().getVideoFirestore().then((_) {
//      List<Video> videos_items = [];
//      videos_splite = [];
      diy_videos = [];
      hair_videos = [];
      random_videos = [];
      searchVideos = [];
      ads_videos = [];
      for (Video item in user_videos) {
        if (item.video_category == query) {
          searchVideos.add(item);
        }
        if (query == "") {
          searchVideos.add(item);
        }
      }
      if (searchVideos.isEmpty) {
        query = "";
        setState(() {});
      }

      for (Video item in searchVideos) {
        if (item.video_category.toUpperCase() != "*ADS" &&
                item.video_tag.toUpperCase() == "RANDOM" ||
            item.video_tag.toUpperCase() == "*RANDOM") {
          random_videos.add(item);
        }
        if (item.video_category.toUpperCase() != "*ADS" &&
                item.video_tag.toUpperCase() == "DIY" ||
            item.video_tag.toUpperCase() == "*DIY") {
          diy_videos.add(item);
        }
        if (item.video_category.toUpperCase() != "*ADS" &&
                item.video_tag.toUpperCase() == "HAIR" ||
            item.video_tag.toUpperCase() == "*HAIR") {
          hair_videos.add(item);
        }
        if (item.video_category.toUpperCase() == "*ADS") {
          ads_videos.add(item);
        }
      }

      for (Video item in ads_videos) {
        int random = Random().nextInt(2);
        print("$random-=------------------------------random");
        switch (random) {
          case 0:
            random_videos.add(item);
            random_videos.sort((a, b) {
              return a.video_category.compareTo(b.video_category);
            });
            break;
          case 1:
            hair_videos.add(item);
            hair_videos.sort((a, b) {
              return a.video_category.compareTo(b.video_category);
            });
            break;
        }
      }
      if (ads_videos.isNotEmpty && isLoading) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    super.dispose();
  }

  _video_init(String video_url) async {
    _controller = VideoPlayerController.network(video_url)
      ..initialize().then((_) {
        setState(() {
          ratio = _controller.value.aspectRatio;
        });
      });
  }

  _refresh() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  Widget _tabView(int index) {
    switch (index) {
      case 0:
        {
          return _HomeView();
        }
        break;
      case 1:
        {
          return _NbxView();
        }
        break;

      case 3:
        {
          return _ShopView();
        }
        break;
      case 4:
        {
          return _TVView();
        }
        break;
      case 5:
        {
          return _AcadView();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    device_width = MediaQuery.of(context).size.width;
    device_height = MediaQuery.of(context).size.height;
    print(device_height);
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      print(appState.isLoading);
      print(appState.firebaseUserAuth);
      print(appState.settings);
      print(appState.user);
      return SignInScreen();
    } else {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
      _refresh();
      //check for null https://stackoverflow.com/questions/49775261/check-null-in-ternary-operation
      final userId = appState?.firebaseUserAuth?.uid ?? '';
      final email = appState?.firebaseUserAuth?.email ?? '';
      final photoUrl = appState?.user?.photoUrl ?? '';
      final firstName = appState?.user?.firstName ?? '';
      final lastName = appState?.user?.lastName ?? '';
      final creat_at = appState?.user?.create_at ?? '';
      if (user_id == null) {
        animation_height = device_height - 150;
        animation_width = device_width;
        user_id = userId;
        user_email = email;
        user_image_url = "";
        user_image_url = photoUrl;
        user_firstname = firstName;
        user_lastname = lastName;
        user_create_at = creat_at;
      }
      print(creat_at);
      print(
          "=================+++++++++++++++++++++++++++++++++=$isLoading ${ads_videos.isNotEmpty}====++++++++++++++++++++++++++++++=======================================");
      if (isLoading && ads_videos.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 100), () {
          showDialog(
              context: context,
              builder: (_) {
                return AdsDialog(
                  video_url:
                      ads_videos[Random().nextInt(ads_videos.length)].video_url,
                );
              });
          isLoading = false;
        });
      }

      return WillPopScope(
          child: Scaffold(
            key: scaffoldKey,
            body: Container(
              height: device_height,
              child: SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        //search bar
                        Padding(
                          padding: EdgeInsets.only(
                              top: 15, bottom: 15, right: 7, left: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              title.toLowerCase() == "venue"
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          check_video_play = false;
                                        });
                                      },
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            Stack(
                                              alignment: Alignment(1.5, -1),
                                              children: <Widget>[
                                                Text(
                                                  "Venue",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      fontFamily:
                                                          "phenomena-bold",
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  "GL",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'phenomena-regular',
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            if (tab_index != 0) {
                                              animation_height = 0;
                                              setState(() {});
                                              Future.delayed(
                                                  Duration(milliseconds: 500),
                                                  () {
                                                tab_index = 0;
                                                animation_height =
                                                    device_height - 150;
                                                animation_width = device_width;
                                                if (_venue_visible) {
                                                  _venue_visible = false;
                                                }
                                                setState(() {
                                                  title = "VENUE";
                                                });
                                              });
                                            }
                                          },
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        ),
                                        Image.asset(
                                          "assets/images/${title.toLowerCase()}.png",
                                          width: 50,
                                          height: 50,
                                        ),
                                      ],
                                    ),
                              title.toLowerCase() == "venue" ||
                                      title.toLowerCase() == "glacad"
                                  ? Container()
                                  : Text(
                                      "${title.toLowerCase()}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 25,
                                          fontFamily: 'phenomena-bold',
                                          fontWeight: FontWeight.bold),
                                    ),
                              Container(
                                width: device_width * 0.5,
                                height: 30,
                                child: SimpleAutoCompleteTextField(
                                  key: key,
                                  controller: _search_controller,
                                  suggestions: searchData,
                                  clearOnSubmit: false,
                                  onFocusChanged: (val) {
                                    print("forcus");
                                    check_video_play = false;
                                    animation_height = 0;
                                    setState(() {});
                                    Future.delayed(Duration(milliseconds: 500),
                                        () {
                                      tab_index = 0;
                                      animation_height = device_height - 150;
                                      animation_width = device_width;
                                      setState(() {
                                        title = "VENUE";
                                      });
                                    });

                                    if (val == "") {
                                      query = "";
                                      setState(() {});
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "mantserrat-bold"),
                                    border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(25.0),
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1)),
                                    enabledBorder: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(25.0),
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1)),
                                    hintText: "*diy, *hair, ...",
                                    suffixIcon:
                                        Icon(Icons.search, color: Colors.black),
                                    fillColor: Colors.white,
                                  ),
                                  submitOnSuggestionTap: true,
                                  textSubmitted: (text) {
                                    print("onSubmit");
                                    bool check = false;
                                    for (String search_item in searchData) {
                                      if (text == search_item) {
                                        check = true;
                                      }
                                    }
                                    if (text == "") {
                                      query = "";
                                    } else {
                                      if (check) {
                                        query = text.split("*")[1];
                                      } else {
                                        _search_controller.text = "";
                                        query = "";
                                      }
                                    }

                                    print(query);
                                    setState(() {});
                                  },
                                ),
                              ),
                              Avatar(user_image_url, userId, scaffoldKey,
                                      context)
                                  .small_logo_home(),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                            height: animation_height,
                            width: animation_width,
                            duration: Duration(milliseconds: 500),
                            child: SingleChildScrollView(
                              child: _tabView(tab_index),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              alignment: Alignment.center,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 30.0, // has the effect of softening the shadow
                    spreadRadius: 2.0, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      0.0, // vertical, move down 10
                    ),
                  )
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 4,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (tab_index != 4) {
                              animation_height = 0;

                              setState(() {});
                              Future.delayed(Duration(milliseconds: 500), () {
                                tab_index = 4;
                                animation_height = device_height - 150;

                                animation_width = device_width;
                                setState(() {
                                  title = "TV";
                                });
                              });
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 40,
                                width: 40,
                                child: new Image.asset(
                                  "assets/images/tv.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Text(
                                "TV",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Nova Round",
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (tab_index != 1) {
                              animation_height = 0;
                              setState(() {});
                              chatUsers =
                                  await TotalUserData().getVideoFirestore();
                              selectedUserCheck = [];
                              chatSearchUsers = [];
                              for (var item in chatUsers) {
                                chatSearchUsers.add(item);
                                print(item.userId);
                                selectedUserCheck.add(false);
                              }
                              Future.delayed(Duration(milliseconds: 500), () {
                                tab_index = 1;
                                animation_height = device_height - 150;
                                animation_width = device_width;

                                setState(() {
                                  title = "NBX";
                                });
                              });
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    width: 40,
                                    child: new Image.asset(
                                      "assets/images/nbx.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Container(
                                    child: StreamBuilder(
                                      stream: FirebaseDatabase.instance
                                          .reference()
                                          .child("chat")
                                          .orderByChild("receiver_id")
                                          .equalTo(user_id)
                                          .onValue,
                                      builder: (context, snap) {
                                        if (snap.hasData &&
                                            !snap.hasError &&
                                            snap.data.snapshot.value != null) {
                                          int i = 0;
                                          snap.data.snapshot.value
                                              .forEach((key, value) {
                                            print(value['is_readed']);
                                            if (!value['is_readed']) i++;
                                          });
                                          return i == 0
                                              ? Container()
                                              : Container(
                                                  padding: EdgeInsets.only(
                                                      left: 3, right: 3),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.red),
                                                  child: Text(
                                                    "$i",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12),
                                                  ),
                                                );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "nbx",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Nova Round",
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            uploaded_video_category = "Other";
                            uploaded_video_tag = "RANDOM";
                            setState(() {
//                          isLoading = true;
                              ads_duration_seconds = 4;
                              if (check_video_play) {
                                _controller.pause();
                                check_video_play = false;
                              } else {
                                if (isUploading) {
                                } else {
                                  _go_shining().then((val) {
                                    if (val == "upload") {
                                      videoPicker.showDialog(context);
                                    }
                                    if (val == "no_shine") {
                                      ToastShow("no shinning...", context,
                                              Colors.red[700])
                                          .init();
                                    }
                                    if (val == "shine") {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              MyShiningList());
                                    }
                                  });
                                }
                              }
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              Stack(
                                alignment: Alignment(0, 0),
                                children: <Widget>[
                                  Container(
                                    height: 55,
                                    width: 55,
                                    child: new Image.asset(
                                      "assets/images/shine.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  isUploading
                                      ? CircularProgressIndicator()
                                      : Container(),
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Text(
                                    "shine",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Nova Round",
                                        color: Colors.red),
                                  )),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (tab_index != 3) {
                              animation_height = 0;

                              setState(() {});
                              Future.delayed(Duration(milliseconds: 500), () {
                                tab_index = 3;
                                animation_height = device_height - 150;
                                animation_width = device_width;

                                setState(() {
                                  title = "SHOP";
                                });
                              });
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 40,
                                width: 40,
                                child: new Image.asset(
                                  "assets/images/shop.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Text(
                                "shop",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Nova Round",
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              if (tab_index != 0) {
                                animation_height = 0;
                                setState(() {});
                                Future.delayed(Duration(milliseconds: 500), () {
                                  animation_height = device_height - 150;
                                  animation_width = device_width;

                                  setState(() {
                                    if (!_venue_visible) {
                                      tab_index = 5;
                                      title = "GLACAD";
                                    } else {
                                      tab_index = 0;
                                      title = "VENUE";
                                    }
                                    _venue_visible = !_venue_visible;
                                  });
                                });
                              }
                              if (tab_index == 0) {
                                animation_height = 0;
                                setState(() {});
                                _venue_visible = !_venue_visible;
                                tab_index = 5;
                                title = "GLACAD";
                                Future.delayed(Duration(milliseconds: 500), () {
                                  animation_height = device_height - 150;
                                  setState(() {});
                                });
                              }
                            },
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  child: AnimatedOpacity(
                                    opacity: _venue_visible ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 500),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 40,
                                          width: 40,
                                          child: new Image.asset(
                                            "assets/images/venue.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Text("venue",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Nova Round",
                                                color: Colors.black))
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: AnimatedOpacity(
                                    opacity: _venue_visible ? 0.0 : 1.0,
                                    duration: Duration(milliseconds: 500),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 40,
                                          width: 40,
                                          child: new Image.asset(
                                            "assets/images/glacad.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Text("Acad",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Nova Round",
                                                color: Colors.black))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          onWillPop: () {
            exit(0);
            return null;
          });
    }
  }

  Widget _TVView() => Container(
        height: device_height - 160,
        child: YouTubeView(),
      );

  Widget _NbxView() {
    return Container(
        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300], width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //nbx search
                Container(
                  height: 50,
                  padding: EdgeInsets.all(5),
                  child: TextField(
                    controller: _search_members_controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: "mantserrat-bold"),
                      border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      enabledBorder: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      hintText: "search for members",
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      print(value);
                      chatSearchUsers = [];
                      selectedUserCheck = [];
                      for (var item in chatUsers) {
                        String name = item.firstName + " " + item.lastName;
                        print(
                            "+++++++++++++++++++++++++++++++++++++++++++++++++");
                        print(name.toLowerCase().contains(value));
                        if (name.toLowerCase().contains(value)) {
                          chatSearchUsers.add(item);
                          selectedUserCheck.add(false);
                        }
                      }
                      setState(() {});
                    },
                  ),
                ),
                //nbx body
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        height: device_height * 0.3,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: chatSearchUsers.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                InkWell(
                                  onTap: () async {
                                    if (!selectedUserCheck[index]) {
                                      FirebaseDatabase.instance
                                          .reference()
                                          .child("chat")
                                          .orderByChild("id")
                                          .equalTo(
                                              chatSearchUsers[index].userId +
                                                  user_id)
                                          .once()
                                          .then((DataSnapshot snap) {
                                        if (snap.value != null) {
                                          Map data = snap.value;
                                          data.forEach((key, value) {
                                            FirebaseDatabase.instance
                                                .reference()
                                                .child("chat")
                                                .child(key)
                                                .update({"is_readed": true});
                                          });
                                        }
                                      });
                                    }
                                    for (int i = 0;
                                        i < selectedUserCheck.length;
                                        i++) {
                                      selectedUserCheck[i] = false;
                                    }
                                    selectedUserCheck[index] = true;
                                    setState(() {});
                                  },
                                  child: Stack(
                                    alignment: Alignment(1.05, -1.05),
                                    children: <Widget>[
                                      Container(
                                          height: device_height * 0.3 - 50,
                                          margin: EdgeInsets.all(5),
                                          width: 80,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      selectedUserCheck[index]
                                                          ? Colors.black
                                                          : Colors.grey,
                                                  width:
                                                      selectedUserCheck[index]
                                                          ? 3
                                                          : 1),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: (chatSearchUsers[index]
                                                            .photoUrl ==
                                                        "" ||
                                                    chatSearchUsers[index]
                                                            .photoUrl ==
                                                        null)
                                                ? Image.asset(
                                                    "assets/images/user.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    chatSearchUsers[index]
                                                        .photoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                          )),
                                      StreamBuilder(
                                          stream: FirebaseDatabase.instance
                                              .reference()
                                              .child("chat")
                                              .orderByChild("receiver_id")
                                              .equalTo("$user_id")
                                              .limitToLast(1)
                                              .onValue,
                                          builder: (context, snap) {
                                            if (snap.hasData &&
                                                !snap.hasError &&
                                                snap.data.snapshot.value !=
                                                    null) {
                                              print(
                                                  "-----------+++++++++++++++++++++------");
                                              bool is_readed = true;
                                              snap.data.snapshot.value
                                                  .forEach((key, value) {
                                                Chat chat = Chat(
                                                    key: "$key",
                                                    sender_id:
                                                        "${value['sender_id']}",
                                                    receiver_id:
                                                        "${value['receive_id']}",
                                                    is_readed:
                                                        value['is_readed'],
                                                    create_at:
                                                        "${value['create_at']}",
                                                    message:
                                                        "${value['message']}",
                                                    fcm_token:
                                                        "${value['fcm_token']}");
                                                if (chat.sender_id ==
                                                    chatSearchUsers[index]
                                                        .userId) {
                                                  print(
                                                      "--------------------------------------------------");
                                                  is_readed = chat.is_readed;
                                                }
                                              });
                                              if (is_readed) {
                                                return Container();
                                              } else {
                                                return Icon(
                                                  Icons.announcement,
                                                  color: Colors.red,
                                                );
                                              }
                                            } else {
                                              return Container();
                                            }
                                          })
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: 80,
                                  child: Text(
                                    "${chatSearchUsers[index].firstName} ${chatSearchUsers[index].lastName}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 0.8,
                        color: Colors.grey[400],
                      ),
                      new Builder(builder: (context) {
                        User selected_user;
                        TextEditingController _send_message_controller =
                            new TextEditingController();
                        TextEditingController _receive_message_controller =
                            new TextEditingController();
                        for (int i = 0; i < chatSearchUsers.length; i++) {
                          if (selectedUserCheck[i]) {
                            selected_user = chatSearchUsers[i];
                          }
                        }
                        return Column(
                          children: <Widget>[
                            selected_user == null
                                ? Container()
                                : (check_ghost_chat
                                    ? Container(
                                        padding: EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1)),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                    child: (selected_user.photoUrl ==
                                                                "" ||
                                                            selected_user
                                                                    .photoUrl ==
                                                                null)
                                                        ? Image.asset(
                                                            "assets/images/user.png")
                                                        : FadeInImage.memoryNetwork(
                                                            placeholder:
                                                                kTransparentImage,
                                                            image:
                                                                "${selected_user.photoUrl}"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "${selected_user.firstName}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            StreamBuilder(
                                              stream: FirebaseDatabase.instance
                                                  .reference()
                                                  .child("chat")
                                                  .orderByChild("id")
                                                  .equalTo(
                                                      selected_user.userId +
                                                          user_id)
                                                  .limitToLast(1)
                                                  .onValue,
                                              builder: (context, snap) {
                                                if (snap.hasData &&
                                                    !snap.hasError &&
                                                    snap.data.snapshot.value !=
                                                        null) {
                                                  Map data =
                                                      snap.data.snapshot.value;
                                                  data.forEach((key, value) {
                                                    _receive_message_controller
                                                            .text =
                                                        "${value['message']}";
                                                  });
                                                } else {
                                                  _receive_message_controller
                                                      .text = "";
                                                }
                                                return Container(
                                                  width: device_width - 130,
                                                  child: TextField(
                                                    controller:
                                                        _receive_message_controller,
                                                    enabled: false,
                                                    maxLines: 10,
                                                    minLines: 3,
                                                    decoration: InputDecoration(
                                                        fillColor: Colors.grey,
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30))),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : StreamBuilder(
                                        stream: FirebaseDatabase.instance
                                            .reference()
                                            .child("chat")
                                            .orderByChild("is_ghost")
                                            .equalTo(false)
                                            .limitToLast(60)
                                            .onValue,
                                        builder: (context, snap) {
                                          List<Chat> chat_list = [];
                                          if (snap.hasData &&
                                              !snap.hasError &&
                                              snap.data.snapshot.value !=
                                                  null) {
                                            Map data = snap.data.snapshot.value;
                                            data.forEach((key, value) {
                                              String chat_id = "${value["id"]}";
                                              if (chat_id ==
                                                      selected_user.userId +
                                                          user_id ||
                                                  chat_id ==
                                                      user_id +
                                                          selected_user
                                                              .userId) {
                                                chat_list.add(Chat(
                                                    key: "$key",
                                                    create_at:
                                                        "${value['create_at']}",
                                                    id: "${value['id']}",
                                                    is_readed:
                                                        value['is_readed'],
                                                    message:
                                                        "${value['message']}",
                                                    receiver_id:
                                                        "${value['receiver_id']}",
                                                    sender_id:
                                                        "${value['sender_id']}"));
                                              }
                                            });
                                          } else {}

                                          chat_list.sort((a, b) {
                                            return a.key
                                                .toString()
                                                .compareTo(b.key.toString());
                                          });
                                          return Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 10,
                                              ),
                                              chat_list.isEmpty
                                                  ? Container()
                                                  : Column(
                                                      children:
                                                          chat_list.map((data) {
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                width: 50,
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            40),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1)),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              40),
                                                                  child: data.sender_id ==
                                                                          user_id
                                                                      ? user_image_url ==
                                                                              ""
                                                                          ? Image.asset(
                                                                              "assets/images/user.png")
                                                                          : FadeInImage.memoryNetwork(
                                                                              placeholder:
                                                                                  kTransparentImage,
                                                                              image:
                                                                                  "$user_image_url")
                                                                      : (selected_user.photoUrl ==
                                                                                  "" ||
                                                                              selected_user.photoUrl ==
                                                                                  null)
                                                                          ? Image.asset(
                                                                              "assets/images/user.png")
                                                                          : FadeInImage.memoryNetwork(
                                                                              placeholder: kTransparentImage,
                                                                              image: "${selected_user.photoUrl}"),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Container(
                                                                width:
                                                                    device_width -
                                                                        130,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.grey,
                                                                        )),
                                                                child: Text(data
                                                                    .message),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                            ],
                                          );
                                        },
                                      )),
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: user_image_url == ""
                                              ? Image.asset(
                                                  "assets/images/user.png")
                                              : FadeInImage.memoryNetwork(
                                                  placeholder:
                                                      kTransparentImage,
                                                  image: "$user_image_url"),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "You",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: device_width - 130,
                                    child: TextField(
                                      onTap: () {
                                        FirebaseDatabase.instance
                                            .reference()
                                            .child("chat")
                                            .orderByChild("id")
                                            .equalTo(
                                                selected_user.userId + user_id)
                                            .once()
                                            .then((DataSnapshot snap) {
                                          if (snap.value != null) {
                                            Map data = snap.value;
                                            data.forEach((key, value) {
                                              FirebaseDatabase.instance
                                                  .reference()
                                                  .child("chat")
                                                  .child(key)
                                                  .update({"is_readed": true});
                                            });
                                          }
                                        });
                                      },
                                      controller: _send_message_controller,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey,
                                          suffix: InkWell(
                                            onTap: () {
                                              String message =
                                                  _send_message_controller.text;
                                              String now =
                                                  DateTime.now().toString();
                                              if (_send_message_controller
                                                          .text !=
                                                      "" &&
                                                  selected_user != null)
                                                ChatData().addMessageDB(Chat(
                                                    id: user_id +
                                                        selected_user.userId,
                                                    message: message,
                                                    sender_id: user_id,
                                                    receiver_id:
                                                        selected_user.userId,
                                                    create_at: now,
                                                    is_readed: false,
                                                    is_ghost:
                                                        check_ghost_chat));
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                            },
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.black,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
//                          Image.asset("assets/images/regular_chat.png", width: 30,),
//                          SizedBox(
//                            width: 5,
//                          ),
//                          Container(
//                            height:30,
//                            width:70,
//                            decoration:BoxDecoration(
//                                color:Colors.white,
//                                border: Border.all(
//                                    color: Colors.black,
//                                    width: 2
//                                ),
//                                borderRadius: BorderRadius.circular(20)
//                            ),
//                            child: Switch(
//                                activeColor: Colors.red[600],
//                                activeTrackColor: Colors.white,
//                                inactiveTrackColor: Colors.white,
//                                inactiveThumbColor: Colors.black,
//                                value: check_ghost_chat,
//                                materialTapTargetSize: MaterialTapTargetSize.padded,
//                                onChanged: (val){
//                                  check_ghost_chat = val;
//                                  setState(() {
//
//                                  });
//                                }),
//                          ),
                          Opacity(
                            opacity: check_ghost_chat ? 1 : 0.2,
                            child: InkWell(
                              onTap: () {
                                check_ghost_chat = !check_ghost_chat;
                                setState(() {});
                              },
                              child: Image.asset(
                                "assets/images/ghost_chat.png",
                                width: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _videoPlay() {
    return Column(
      children: <Widget>[
        Container(
//      height: MediaQuery.of(context).size.width*0.9,
          width: MediaQuery.of(context).size.width * 0.7,
          padding: EdgeInsets.all(10),
          child: GestureDetector(
              onDoubleTap: () {
                check_video_play = false;
                if (_controller == null || user_id == current_video.user_id) {
                  _video_full_screen_go();
                } else {
                  print("-=-=-=-=-=-=-=");
                  print(current_video.user_email);
                  current_video.video_view_count =
                      current_video.video_view_count == null
                          ? 0
                          : current_video.video_view_count;
                  current_video.video_view_count++;
                  VideoData().updateVideoCount(current_video.video_view_count,
                      current_video.key, "video_view_count");
                  _video_full_screen_go();
                }
              },
              onTap: () {},
              onTapDown: (_) {
                setState(() {
                  video_click_opacity = 0.4;
                });
              },
              onTapUp: (_) {
                setState(() {
                  video_click_opacity = 1;
                });
              },
              onTapCancel: () {
                setState(() {
                  video_click_opacity = 1;
                });
              },
              child: Opacity(
                opacity: video_click_opacity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: new Chewie(
                            _controller,
                            aspectRatio: device_width / device_height,
                            autoPlay: false,
                            looping: true,
                          ),
                        ),
                        Positioned(
                          child: new Builder(
                            builder: (context) {
                              String cat_icon_name;
                              try {
                                cat_icon_name = current_video.video_description;
                              } catch (e) {}
                              print(cat_icon_name);
                              return cat_icon_name == "null"
                                  ? Image.asset(
                                      "assets/category/${current_video.video_category}.png",
                                    )
                                  : Image.asset(
                                      "assets/category/$cat_icon_name.png",
                                    );
                            },
                          ),
                          top: -7,
                          right: -11,
                        ),
                        Positioned(
                          top: 3,
                          left: 3,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Avatar(
                                        current_video.user_id == user_id
                                            ? user_image_url
                                            : current_video.user_image_url,
                                        current_video.user_id,
                                        scaffoldKey,
                                        context)
                                    .small_logo_home(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, bottom: 5, right: 20, left: 10),
                                ),
                                Text(
                                  current_video.user_id == user_id
                                      ? "$user_firstname $user_lastname"
                                      : current_video.user_name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'NovaRound-Regular'),
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 50,
                            left: 15,
                            child: Container(
                              width: device_width / 2 + 10,
                              child: Text(
                                current_video.video_title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "phenomena-bold",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              )),
        ),
        Container(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance
                .reference()
                .child('message')
                .orderByChild('videoKey')
                .equalTo(current_video.key) //order by creation time.
                .onValue,
            builder: (context, snap) {
              if (snap.hasData &&
                  !snap.hasError &&
                  snap.data.snapshot.value != null) {
                DataSnapshot snapshot = snap.data.snapshot;
                List<ChatMessage> messages = [];

                snapshot.value.forEach((key, value) {
                  if (value != null) {
                    print(value);
                    ChatMessage messageItem = ChatMessage(
                        key: "$key",
                        videoKey: "${value['videoKey']}",
                        userid: "${value['userid']}",
                        username: "${value['username']}",
                        user_create_at: "${value['user_create_at']}",
                        photoUrl: "${value['photoUrl']}",
                        message: "${value['message']}");
                    print(messageItem.message);
                    messages.add(messageItem);
                  }
                });

                messages.sort((a, b) {
                  return a.key.toString().compareTo(b.key.toString());
                });

                return snap.data.snapshot.value == null
                    ? SizedBox()
//otherwise return a list of widgets.
                    : Column(
                        children: messages.map((item) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Avatar(item.photoUrl, item.username, scaffoldKey,
                                      context)
                                  .small_logo_message(),
                              Container(
                                width: device_width - 60,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(item.message),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList());
              } else {
                return Center(child: Container());
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
                icon: Avatar(user_image_url, user_id, scaffoldKey, context)
                    .small_logo_message(),
                hintText: "Insert message.",
                suffixIcon: InkWell(
                  child: Icon(Icons.send),
                  onTap: () {
                    var now = DateTime.now().toString();
                    if (_messageController.text != "") {
                      MessageData().addMessageDB(ChatMessage(
                          videoKey: current_video.key,
                          userid: user_id,
                          username: "${user_firstname} ${user_lastname}",
                          user_create_at: user_create_at,
                          photoUrl: user_image_url,
                          message: _messageController.text,
                          created_at: now));
                      setState(() {
                        _messageController.text = "";
                      });
                    }
                  },
                )),
          ),
        ),
      ],
    );
  }

  Widget _videoList() => FutureBuilder(
        future: _initVideoData(),
        builder: (context, snap) {
          return Column(
            children: <Widget>[
              user_videos.isEmpty
                  ? Container(
                      child: Text("empty"),
                    )
                  : Container(
                      height: device_height - 160,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: diy_videos.isEmpty
                                ? Container(
                                    height: (device_height - 160) / 3,
                                    child: Center(
                                      child: Text(
                                        "DIY",
                                        style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 20),
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
                                    autoPlayInterval:
                                        Duration(milliseconds: 5000),
                                    autoPlayCurve: Curves.linear,
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 5000),
                                    pauseAutoPlayOnTouch: Duration(seconds: 2),
                                    onPageChanged: (c) {},
                                    scrollDirection: Axis.horizontal,
                                    items: diy_videos.map((video) {
                                      i++;
                                      return InkWell(
                                          onTap: () {
                                            if (video.video_category
                                                    .toUpperCase() !=
                                                "*ADS") {
                                              _video_init(video.video_url);
                                              setState(() {
                                                check_video_play = true;
                                                current_video = video;
                                              });
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AdsDialog(
                                                        video_url:
                                                            video.video_url,
                                                      ));
                                            }
                                          },
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                height: (device_height - 150) *
                                                    0.35,
                                                width: device_width,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 4, right: 4),
                                                      decoration: BoxDecoration(
                                                        border: video
                                                                    .video_category
                                                                    .toUpperCase() ==
                                                                "*ADS"
                                                            ? Border.all(
                                                                color: Colors
                                                                    .green,
                                                                width: 4)
                                                            : null,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23),
                                                        boxShadow: [
                                                          new BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              offset:
                                                                  new Offset(
                                                                      0, 4),
                                                              blurRadius: 4),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: FadeInImage
                                                            .memoryNetwork(
                                                          placeholder:
                                                              kTransparentImage,
                                                          image:
                                                              video.image_url,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      child: new Builder(
                                                        builder: (context) {
                                                          String cat_icon_name;
                                                          try {
                                                            cat_icon_name = video
                                                                .video_description;
                                                          } catch (e) {}
                                                          print(cat_icon_name);
                                                          return cat_icon_name ==
                                                                  "null"
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
                                                    top: 5,
                                                    bottom: 5,
                                                    right: 30,
                                                    left: 30),
                                              ),
                                              StreamBuilder(
                                                stream: FirebaseDatabase
                                                    .instance
                                                    .reference()
                                                    .child("video")
                                                    .child("${video.key}")
                                                    .onValue,
                                                builder: (context, snap) {
                                                  bool isStreaming = false;
                                                  if (snap.hasData &&
                                                      !snap.hasError &&
                                                      snap.data.snapshot
                                                              .value !=
                                                          null) {
                                                    Map data = snap
                                                        .data.snapshot.value;
                                                    print("-=-=-=-=-=-=-");
                                                    isStreaming =
                                                        data['isStreaming'];
                                                    print(data['isStreaming']);
                                                  }

                                                  return isStreaming
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : Container();
                                                },
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 5,
                                                    bottom: 5,
                                                    right: 31,
                                                    left: 30),
                                                child: Container(
                                                  height:
                                                      (device_height - 150) *
                                                          0.35,
                                                  width: device_width,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      stops: [
                                                        0.0,
                                                        0.5,
                                                        0.7,
                                                        1.0
                                                      ],
                                                      colors: [
                                                        Colors.grey
                                                            .withOpacity(0.0),
                                                        Colors.black54
                                                            .withOpacity(0.3),
                                                        Colors.black26
                                                            .withOpacity(0.5),
                                                        Colors.black
                                                            .withOpacity(0.7),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                      bottom: 40,
                                                      left: 50,
                                                      child: Text(
                                                        "${video.video_title}",
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                            ],
                                          ));
                                    }).toList(),
                                  ),
                          ),
                          CarouselSlider(
                            height: (device_height - 160) * 0.65,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            viewportFraction: 0.9,
                            autoPlay: true,
                            autoPlayInterval: Duration(milliseconds: 4000),
                            autoPlayCurve: Curves.linear,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 4000),
                            pauseAutoPlayOnTouch: Duration(seconds: 1),
                            onPageChanged: (c) {},
                            scrollDirection: Axis.horizontal,
                            items: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    height: (device_height - 160) * 0.64,
                                    width: device_width - 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.yellow,
                                    ),
                                  ),
                                  Container(
                                    height: (device_height - 150) * 0.64,
                                    width: device_width - 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.0, 0.5, 0.7, 1.0],
                                        colors: [
                                          Colors.grey.withOpacity(0.0),
                                          Colors.black54.withOpacity(0.3),
                                          Colors.black26.withOpacity(0.5),
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                child: Stack(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          child: hair_videos.isEmpty
                                              ? Container(
                                                  height:
                                                      (device_height - 160) *
                                                          0.34,
                                                  child: Center(
                                                    child: Text(
                                                      "HAIR",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[300],
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height:
                                                      (device_height - 160) *
                                                          0.35,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        hair_videos.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      Video video =
                                                          hair_videos[index];
                                                      return InkWell(
                                                        onTap: () {
                                                          if (video
                                                                  .video_category
                                                                  .toUpperCase() !=
                                                              "*ADS") {
                                                            _video_init(video
                                                                .video_url);
                                                            setState(() {
                                                              check_video_play =
                                                                  true;
                                                              current_video =
                                                                  video;
                                                            });
                                                          } else {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AdsDialog(
                                                                          video_url:
                                                                              video.video_url,
                                                                        ));
                                                          }
                                                        },
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Container(
                                                              height:
                                                                  (device_height -
                                                                          150) *
                                                                      0.35,
                                                              width: 300,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    border: video.video_category.toUpperCase() ==
                                                                            "*ADS"
                                                                        ? Border.all(
                                                                            color: Colors
                                                                                .blue,
                                                                            width:
                                                                                4)
                                                                        : null,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23)),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: FadeInImage
                                                                      .memoryNetwork(
                                                                    placeholder:
                                                                        kTransparentImage,
                                                                    image: video
                                                                        .image_url,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 5,
                                                                      bottom: 5,
                                                                      right: 20,
                                                                      left: 10),
                                                            ),
                                                            StreamBuilder(
                                                              stream: FirebaseDatabase
                                                                  .instance
                                                                  .reference()
                                                                  .child(
                                                                      "video")
                                                                  .child(
                                                                      "${video.key}")
                                                                  .onValue,
                                                              builder: (context,
                                                                  snap) {
                                                                bool
                                                                    isStreaming =
                                                                    false;
                                                                if (snap.hasData &&
                                                                    !snap
                                                                        .hasError &&
                                                                    snap.data.snapshot
                                                                            .value !=
                                                                        null) {
                                                                  Map data = snap
                                                                      .data
                                                                      .snapshot
                                                                      .value;
                                                                  print(
                                                                      "-=-=-=-=-=-=-");
                                                                  isStreaming =
                                                                      data[
                                                                          'isStreaming'];
                                                                  print(data[
                                                                      'isStreaming']);
                                                                }

                                                                return isStreaming
                                                                    ? Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      )
                                                                    : Container();
                                                              },
                                                            ),
                                                            Positioned(
                                                              child:
                                                                  new Builder(
                                                                builder:
                                                                    (context) {
                                                                  String
                                                                      cat_icon_name;
                                                                  try {
                                                                    cat_icon_name =
                                                                        video
                                                                            .video_description;
                                                                  } catch (e) {}
                                                                  print(
                                                                      cat_icon_name);
                                                                  return cat_icon_name ==
                                                                          "null"
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/category/${video.video_category}.png",
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          "assets/category/$cat_icon_name.png",
                                                                        );
                                                                },
                                                              ),
                                                              top: 0,
                                                              right: 10,
                                                            ),
                                                            
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 5,
                                                                      bottom: 5,
                                                                      right: 20,
                                                                      left: 10),
                                                              child: Container(
                                                                height:
                                                                    (device_height -
                                                                            150) *
                                                                        0.35,
                                                                width: 270,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              23),
                                                                  gradient:
                                                                      LinearGradient(
                                                                    begin: Alignment
                                                                        .topCenter,
                                                                    end: Alignment
                                                                        .bottomCenter,
                                                                    stops: [
                                                                      0.0,
                                                                      0.5,
                                                                      0.7,
                                                                      1.0
                                                                    ],
                                                                    colors: [
                                                                      Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.0),
                                                                      Colors
                                                                          .black54
                                                                          .withOpacity(
                                                                              0.3),
                                                                      Colors
                                                                          .black26
                                                                          .withOpacity(
                                                                              0.3),
                                                                      Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.7),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 40,
                                                              left: 30,
                                                              child: Text(
                                                                "${video.video_title}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        22,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                        Container(
                                          child: random_videos.isEmpty
                                              ? Container(
                                                  height:
                                                      (device_height - 160) *
                                                          0.3,
                                                  child: Center(
                                                    child: Text(
                                                      "RANDOM",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[300],
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height:
                                                      (device_height - 160) *
                                                          0.3,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        random_videos.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      Video video =
                                                          random_videos[index];
                                                      return InkWell(
                                                          onTap: () {
                                                            if (video
                                                                    .video_category
                                                                    .toUpperCase() !=
                                                                "*ADS") {
                                                              _video_init(video
                                                                  .video_url);
                                                              setState(() {
                                                                check_video_play =
                                                                    true;
                                                                current_video =
                                                                    video;
                                                              });
                                                            } else {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          AdsDialog(
                                                                            video_url:
                                                                                video.video_url,
                                                                          ));
                                                            }
                                                          },
                                                          child: Stack(
                                                            children: <Widget>[
                                                              Container(
                                                                height:
                                                                    (device_height -
                                                                            150) *
                                                                        0.3,
                                                                width: 250,
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      border: video.video_category.toUpperCase() ==
                                                                              "*ADS"
                                                                          ? Border.all(
                                                                              color: Colors
                                                                                  .green,
                                                                              width:
                                                                                  4)
                                                                          : null,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              23)),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    child: FadeInImage
                                                                        .memoryNetwork(
                                                                      placeholder:
                                                                          kTransparentImage,
                                                                      image: video
                                                                          .image_url,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            20,
                                                                        left:
                                                                            0),
                                                              ),
                                                              StreamBuilder(
                                                                stream: FirebaseDatabase
                                                                    .instance
                                                                    .reference()
                                                                    .child(
                                                                        "video")
                                                                    .child(
                                                                        "${video.key}")
                                                                    .onValue,
                                                                builder:
                                                                    (context,
                                                                        snap) {
                                                                  bool
                                                                      isStreaming =
                                                                      false;
                                                                  if (snap.hasData &&
                                                                      !snap
                                                                          .hasError &&
                                                                      snap.data.snapshot
                                                                              .value !=
                                                                          null) {
                                                                    Map data = snap
                                                                        .data
                                                                        .snapshot
                                                                        .value;
                                                                    print(
                                                                        "-=-=-=-=-=-=-");
                                                                    isStreaming = data['isStreaming'] ==
                                                                            null
                                                                        ? false
                                                                        : data[
                                                                            'isStreaming'];
                                                                    print(data[
                                                                        'isStreaming']);
                                                                  }

                                                                  return isStreaming
                                                                      ? Center(
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              CircularProgressIndicator(),
                                                                              Text(
                                                                                "Shinning...",
                                                                                style: TextStyle(
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Container();
                                                                },
                                                              ),
                                                              Positioned(
                                                                child:
                                                                    new Builder(
                                                                  builder:
                                                                      (context) {
                                                                    String
                                                                        cat_icon_name;
                                                                    try {
                                                                      cat_icon_name =
                                                                          video
                                                                              .video_description;
                                                                    } catch (e) {}
                                                                    print(
                                                                        cat_icon_name);
                                                                    return cat_icon_name ==
                                                                            "null"
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/category/${video.video_category}.png",
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            "assets/category/$cat_icon_name.png",
                                                                          );
                                                                  },
                                                                ),
                                                                top: 0,
                                                                right: 10,
                                                              ),
                                                              
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            20,
                                                                        left:
                                                                            0),
                                                                child:
                                                                    Container(
                                                                  height: (device_height -
                                                                          150) *
                                                                      0.35,
                                                                  width: 230,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23),
                                                                    gradient:
                                                                        LinearGradient(
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment
                                                                          .bottomCenter,
                                                                      stops: [
                                                                        0.0,
                                                                        0.5,
                                                                        0.7,
                                                                        1.0
                                                                      ],
                                                                      colors: [
                                                                        Colors
                                                                            .grey
                                                                            .withOpacity(0.0),
                                                                        Colors
                                                                            .black54
                                                                            .withOpacity(0.3),
                                                                        Colors
                                                                            .black26
                                                                            .withOpacity(0.3),
                                                                        Colors
                                                                            .black
                                                                            .withOpacity(0.7),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                bottom: 30,
                                                                left: 15,
                                                                child: Text(
                                                                  "${video.video_title}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ),
                                                            ],
                                                          ));
                                                    },
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          );
        },
      );
  //////////////////////////////////////////home/////////////////////////////////////////////////
  Widget _HomeView() => Container(
          child: Column(
        children: <Widget>[check_video_play ? _videoPlay() : _videoList()],
      ));

  Widget _ShopView() => Container(
          child: Center(
        child: Text("Shop"),
      ));

  Widget _AcadView() => Container(
          child: Center(
        child: Text("Acad"),
      ));

  Future<void> _video_full_screen_go() async {
    String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) =>
                Video_small_play(_controller, current_video)));
    setState(() {});
  }

  Future<String> _go_shining() async {
    String result =
        await showDialog(context: context, builder: (_) => MyShining());
    print(result);
    return result;
  }

  Future<String> _video_upload_detail_go(File _image) async {
    String returnVal =
        await showDialog(context: context, builder: (_) => MyDialog(_image));
    print(returnVal);
    return returnVal;
  }

  @override
  userVideo(File _video) async {
    final DateTime now = DateTime.now();
    final String millSeconds = now.millisecond.toString();
    final String year = now.year.toString();
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String today = ('$year-$month-$date');
    print(_video.path.split(".").last);

    if (_video != null) {
      if (_video.path.split(".").last == "mp4") {
        setState(() {
          isUploading = true;
        });
        try {
          await GetThumbnails()
              .getThumbnailsImage(_video.path)
              .then((_image) async {
            if (_image != null) {
              _video_upload_detail_go(_image).then((check_success) async {
//                SystemChrome.setEnabledSystemUIOverlays([]);
                if (check_success == "success") {
                  ToastShow("Video is uploading ...", context, Colors.black)
                      .init();
                  await Storage()
                      .uploadFile(_image, "$user_id/$today/$millSeconds")
                      .then((image_url) async {
                    await Storage()
                        .uploadFile(_video, "$user_id/$today/$millSeconds")
                        .then((video_url) async {
                      print(video_url);
                      print(image_url);
                      if (video_url != "Failed") {
                        int random = Random().nextInt(1000000000);
                        String video_id = "$random-$millSeconds";
                        Video video = Video(
                            ID: video_id,
                            video_url: video_url,
                            video_category: uploaded_video_category,
                            image_url: image_url,
                            user_id: user_id,
                            user_name: "$user_firstname $user_lastname",
                            user_image_url: user_image_url,
                            user_create_at: user_create_at,
                            user_email: user_email,
                            video_title: uploaded_video_title,
                            video_tag: uploaded_video_tag,
                            video_description: uploaded_video_description,
                            video_groomlyfe_count: 0,
                            video_view_count: 0,
                            video_like_count: 0,
                            isStreaming: false);
                        VideoData().addVideoDB(video);
                        setState(() {
                          isUploading = false;
                        });
                        ToastShow("Success!", context, Colors.green[700])
                            .init();
                        animation_height = 0;
                        setState(() {});
                        Future.delayed(Duration(milliseconds: 500), () {
                          tab_index = 0;
                          animation_height = device_height - 150;
                          animation_width = device_width;
                          setState(() {
                            title = "VENUE";
                          });
                        });
                        print("added");
                      } else {
                        setState(() {
                          ToastShow("Faild!", context, Colors.red[700]).init();
                          isUploading = false;
                        });
                      }
                    });
                  });
                } else {
                  setState(() {
                    ToastShow("Faild!", context, Colors.red[700]).init();
                    isUploading = false;
                  });
                }
              });
            } else {
              setState(() {
                ToastShow("Faild!", context, Colors.red[700]).init();
                isUploading = false;
              });
            }
          });
        } catch (e) {
          setState(() {
            ToastShow("Faild!", context, Colors.red[700]).init();
            isUploading = false;
          });
        }
      } else {
        setState(() {
          ToastShow("Faild! Invalid Video Type!", context, Colors.red[700])
              .init();
          isUploading = false;
        });
      }
    } else {
      setState(() {
        ToastShow("Faild!", context, Colors.red[700]).init();
        isUploading = false;
      });
    }
  }
}
