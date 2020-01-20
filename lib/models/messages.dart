import 'package:firebase_database/firebase_database.dart';

class ChatMessage{

  String key;
  String videoKey;
  String userid;
  String username;
  String user_create_at;
  String photoUrl;
  String message;
  String created_at;

  ChatMessage({this.key, this.videoKey,this.userid, this.username,this.user_create_at, this.photoUrl, this.message, this.created_at});

  ChatMessage.fromSnapshot(DataSnapshot snapshot,String username)
      : photoUrl = snapshot.value['photoUrl'],
        message = snapshot.value['message'],
        username = snapshot.value['username'],
        videoKey = snapshot.value['videoKey'],
        created_at = snapshot.value['created_at'];

  toJson() {
    return {
      'videoKey' : videoKey,
      'userid': userid,
      'username': username,
      'photoUrl': photoUrl,
      'message': message,
      'created_at': created_at
    };
  }
}

class Chat{
  String key;
  String id;
  String message;
  String sender_id;
  String receiver_id;
  bool is_readed;
  bool is_ghost;
  String create_at;
  String fcm_token;
  Chat({this.key,this.id, this.message, this.sender_id, this.receiver_id, this.is_readed, this.create_at, this.fcm_token, this.is_ghost});
  toJson() {
    return {
      'id':id,
      'message':message,
      'sender_id':sender_id,
      'receiver_id':receiver_id,
      'is_readed':is_readed,
      'create_at':create_at,
      'fcm_token':fcm_token,
      'is_ghost':is_ghost,
    };
  }
}