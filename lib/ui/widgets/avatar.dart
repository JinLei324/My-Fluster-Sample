import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:groomlyfe/ui/screens/profile.dart';
import 'package:video_player/video_player.dart';

class Avatar {
  String photo_url;
  String user_id;
  BuildContext context;
  var scaffold_key = new GlobalKey<ScaffoldState>();
  Avatar(this.photo_url,this.user_id, this.scaffold_key,this.context);

  Widget small_logo_home(){
    return  GestureDetector(child: Container(
        width:40,
        height: 40,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: new ClipRRect(borderRadius: BorderRadius.circular(20),
            child: photo_url == ""?Image.asset("assets/images/user.png", fit: BoxFit.cover,):
            FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: photo_url,width: 40,height: 40,fit: BoxFit.cover,))
    ),onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(photo_url,user_id)));
    });
  }
  Widget small_logo_video(VideoPlayerController _controller){
    return  GestureDetector(child: Container(
        width:40,
        height: 40,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(
            color: Colors.grey,
            width: 2,
          ),
        ),
        child: new ClipRRect(borderRadius: BorderRadius.circular(20),
            child: photo_url == ""?Image.asset("assets/images/user.png",fit: BoxFit.cover,):
            FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: photo_url,width: 40,height: 40,fit: BoxFit.cover,))
    ),onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(photo_url,user_id))),);
  }
  Widget small_logo_message(){
    return  Container(
        width:40,
        height: 40,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(
            color: Colors.grey,
            width: 2,
          ),
        ),
        child: new ClipRRect(borderRadius: BorderRadius.circular(20),
            child: photo_url == ""?Image.asset("assets/images/user.png",fit: BoxFit.cover,):
            FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: photo_url,width: 40,height: 40,fit: BoxFit.cover,))
    );
  }
}