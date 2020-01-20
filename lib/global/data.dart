import 'package:groomlyfe/models/video.dart';
import 'package:video_player/video_player.dart';
import 'package:groomlyfe/models/categories.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

List<Video> user_videos=[];
double device_width=0.0;
double device_height=0.0;
double animation_height=0.0;
double animation_width=0.0;
Color animation_color = Colors.white;



VideoPlayerController background_video_controller;
List<Categories> categories;

String uploaded_video_category;
String uploaded_video_title;
String uploaded_video_description;
String uploaded_video_tag;

String user_id;
String user_firstname;
String user_lastname;
String user_email;
String user_image_url;
String user_create_at;

int tab_index = 0;

List<String> searchData = ['*','*Gaming','*Fashion','*Music', '*Hair', '*Sports','*Health and Fitness','*DIY','*Orther'];

int ads_duration_seconds=3;

final FirebaseMessaging firebaseMessaging =FirebaseMessaging();


