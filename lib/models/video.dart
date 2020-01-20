import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

Video userFromJson(String str) {
  final jsonData = json.decode(str);
  return Video.fromJson(jsonData);
}

String userToJson(Video data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Video {
  String key;
  String ID;
  String user_id;
  String user_email;
  String user_image_url;
  String user_name;
  String user_create_at;

  String image_url;
  String video_url;
  String video_category;
  String video_title;
  String video_description;
  String video_tag;
  int video_view_count;
  int video_like_count;
  int video_groomlyfe_count;
  bool isStreaming;
  String current_time;
  String end_time;

  Video({
    this.key,
    this.ID,
    this.user_id,
    this.user_email,
    this.user_image_url,
    this.user_name,
    this.user_create_at,
    this.image_url,
    this.video_url,
    this.video_category,
    this.video_title,
    this.video_tag,
    this.video_description,
    this.video_view_count,
    this.video_like_count,
    this.video_groomlyfe_count,
    this.isStreaming,
    this.current_time,
    this.end_time,
  });

  factory Video.fromJson(Map<String, dynamic> json) => new Video(
    ID: json["ID"],
    user_id: json["user_id"],
    user_email: json["user_email"],
    user_image_url: json["user_image_url"],
    user_name: json["user_name"],


    image_url: json["image_url"],
    video_url: json["video_url"],
    video_category: json["video_category"],
    video_title: json["video_title"],
    video_tag: json["video_tag"],
    video_description: json['video_description'],
    video_view_count: json['video_view_count']==null?0:json['video_view_count'],
    video_like_count: json['video_like_count']==null?0:json['video_like_count'],
    video_groomlyfe_count: json['video_groomlyfe_count']==null?0:json['video_groomlyfe_count'],
    isStreaming: !json['isStreaming']?false:json['isStreaming'],
  );

  Map<String, dynamic> toJson() => {
    "ID": ID,
    "user_id": user_id,
    "user_email": user_email,
    "user_image_url": user_image_url,
    "user_name": user_name,
    "user_create_at": user_create_at,
    "image_url":image_url,
    "video_url": video_url,
    "video_category": video_category,
    "video_title":video_title,
    "video_description":video_description,
    "video_tag":video_tag,
    "video_like_count":video_like_count,
    "video_view_count":video_view_count,
    "video_groomlyfe_count":video_groomlyfe_count,
    "isStreaming":isStreaming,
    "current_time":current_time,
    "end_time": end_time,
  };

  factory Video.fromDocument(DocumentSnapshot doc) {
    return Video.fromJson(doc.data);
  }
}