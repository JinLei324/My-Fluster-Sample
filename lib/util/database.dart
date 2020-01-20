import 'package:groomlyfe/models/video.dart';
import 'package:groomlyfe/models/messages.dart';
import 'package:groomlyfe/models/user.dart';
import 'package:groomlyfe/models/praise.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:firebase_database/firebase_database.dart';

class VideoData{
  Future<void> addVideoDB(Video video)async{
    await FirebaseDatabase.instance.reference().child('video').push().set(video.toJson()).then((ref){
      return;
    });
  }


  Future<void> getVideoFirestore()async{
    Video video;
    await FirebaseDatabase.instance.reference().child("video").orderByKey().once().then((DataSnapshot snapshot){
      user_videos = [];
      print(snapshot.value);
      Map values = snapshot.value;
      values.forEach((key,values){
        video = Video(key:key,ID: "${values['ID']}",image_url: "${values['image_url']}",video_url: "${values['video_url']}",video_category: "${values['video_category']}",
          user_id: "${values['user_id']}",user_email: "${values['user_email']}",user_image_url: "${values['user_image_url']}",user_name: "${values['user_name']}",user_create_at: "${values['user_create_at']}",
          video_description: "${values['video_description']}", video_tag: "${values['video_tag']}", video_title: "${values['video_title']}",video_view_count: values['video_view_count'],
          video_like_count: values['video_like_count'],video_groomlyfe_count: values['video_groomlyfe_count'],isStreaming: values['isStreaming']==null?false:values['isStreaming']
        );
        user_videos.add(video);
      });
    });
  }

  Future<void> updateVideoCount(int count, String key, String type){
    print(key);
    FirebaseDatabase.instance.reference()
        .child('video').child('$key').update({
      '$type': count   //yes I know.
    });
  }

  Future<void> praiseVideo(Praise praise, String check_praise){

    print(praise.id);
    FirebaseDatabase.instance.reference().child("video_praise").orderByChild("id").equalTo(praise.id).once().then((DataSnapshot dataSnapshot){
      Map data = dataSnapshot.value;
      print("+_+_+_+_+_+_+_+_+$data");
      if(data == null){
        FirebaseDatabase.instance.reference().child("video_praise").push().set(praise.toJson());
      }else{
        data.forEach((key, value){
          print("$key jdklsajfkldsajklfjadslfjkl");
          FirebaseDatabase.instance.reference().child("video_praise").child("${key}").update({
            "$check_praise": true
          });
        });
      }
    });
  }
}

class MessageData{
  Future<void> addMessageDB(ChatMessage message)async{
    await FirebaseDatabase.instance.reference().child('message').push().set(message.toJson()).then((ref){
      return;
    });
  }
}

class ChatData{
  Future<void> addMessageDB(Chat message)async{
    FirebaseDatabase.instance.reference().child('chat').push().set(message.toJson());
  }
}

class TotalUserData{
  Future<List<User>> getVideoFirestore()async{
    List<User> users=[];
    try{
      await FirebaseDatabase.instance.reference().child("user").once().then((DataSnapshot snapshot){
        user_videos = [];
        print(snapshot.value);
        Map values = snapshot.value;
        values.forEach((key,values){
          User user;
          user = User(userId: "${values['userId']}",firstName: "${values['firstName']}", lastName: "${values['lastName']}",
              email: "${values['email']}", photoUrl: "${values['photoUrl']}",create_at: "${values['create_at']}");
          if(user.userId!=user_id){
            users.add(user);
          }
        });
      });
    }catch(e){

    }

    return users;
  }
}