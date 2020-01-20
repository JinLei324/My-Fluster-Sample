import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:groomlyfe/global/data.dart';
import 'package:groomlyfe/ui/screens/home.dart';
import 'package:groomlyfe/util/state_widget.dart';
import 'package:groomlyfe/ui/widgets/profileEdit.dart';
import 'package:groomlyfe/util/auth.dart';


class Profile extends StatefulWidget{
  String image_url;
  String user_id;
  Profile(this.image_url, this.user_id);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileState(image_url,user_id);
  }
}

class ProfileState extends State<Profile>{

  String imageurl;
  String userid;
  int favNumber=0;
  int faceNumber=0;
  int starNumber=0;

  String userName;
  String userCreateAt;


  ProfileState(this.imageurl,this.userid);

  @override
  void initState() {
    _getUserInfo();

    // TODO: implement initState
    super.initState();
  }

  _getUserInfo(){
    if(user_id==userid){
      imageurl = user_image_url;
      userName = user_firstname+" "+user_lastname;
      userCreateAt = user_create_at;
    }
    if(user_videos.isNotEmpty){
      for(var item in user_videos){
        if(item.user_id==userid){
          favNumber+=item.video_like_count;
          faceNumber+=item.video_view_count;
          starNumber+=item.video_groomlyfe_count;
          if(user_id!=userid){
            userName = item.user_name;
            userCreateAt = item.user_create_at;
            imageurl = item.user_image_url;
          }
        }
      }
    }
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        width: device_width,
        height: device_height,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //logo
              Stack(
                alignment: Alignment(1, 1),
                children: <Widget>[
                  Container(
                      width:130,
                      height: 130,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        border: new Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      child: new ClipRRect(borderRadius: BorderRadius.circular(65),
                          child: imageurl == ""?Image.asset("assets/images/user.png",fit: BoxFit.cover,):
                          FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: imageurl,width: 130,height: 130,fit: BoxFit.cover,))
                  ),
                  InkWell(
                      onTap: (){
                        print("edit");
                      },
                      child: Container(
                          width:40,
                          height: 40,
                          decoration: new BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 10.0, // has the effect of softening the shadow
                                spreadRadius: 1.0, // has the effect of extending the shadow
                              )
                            ],
                            border: new Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: new ClipRRect(borderRadius: BorderRadius.circular(20),
                              child:Icon(Icons.star,size: 20,color: Colors.red[500]))
                      )
                  ),
                ],
              ),

              //name&member
              userName==null?Center(child: CircularProgressIndicator(),)
                  :Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "$userName",
                        style: TextStyle(
                            fontFamily: "phenomena-bold",
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        "member since $userCreateAt",
                        style: TextStyle(
                            fontFamily: "phenomena-bold",
                            fontSize: 14,
                            color: Colors.black,
                        ),
                      ),
                    ],
                  )
              ),

              //check_numbers
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.favorite,color: Colors.black,),
                          Text(
                            "$favNumber",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.face,color: Colors.black,),
                          Text(
                            "$faceNumber",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.star,color: Colors.black,),
                          Text(
                            "$starNumber",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(padding: EdgeInsets.all(5)),
              //edit profile
              Container(
                padding: EdgeInsets.all(3),
                child: userid==user_id?InkWell(
                  onTap: ()async{
                    await Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileEdit()));
                    setState(() {
                      userName = "$user_firstname $user_lastname";
                      userCreateAt = user_create_at;
                      imageurl = user_image_url;
                    });
                  },
                  child: Text(
                    "edit profile",
                    style: TextStyle(
                        fontFamily: "phenomena-bold",
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ):
                Text(
                  "edit profile",
                  style: TextStyle(
                      fontFamily: "phenomena-bold",
                      fontSize: 30,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),

              //shop
              Container(
                padding: EdgeInsets.all(3),
                child: InkWell(
                  onTap: (){
                    print("venue");
                    tab_index = 0;
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));

                  },
                  child: Text(
                    "venue",
                    style: TextStyle(
                        fontFamily: "phenomena-bold",
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              //edit profile
              Container(
                padding: EdgeInsets.all(3),
                child: InkWell(
                  onTap: (){
                    print("nbx");
                    tab_index = 1;
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                  },
                  child: Text(
                    "Nbx",
                    style: TextStyle(
                        fontFamily: "phenomena-bold",
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              //GLTV
              Container(
                padding: EdgeInsets.all(3),
                child: InkWell(
                  onTap: (){
                    print("shop");
                    tab_index = 3;
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                  },
                  child: Text(
                    "shop",
                    style: TextStyle(
                        fontFamily: "phenomena-bold",
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              //GroomLyfe Academy
              Container(
                padding: EdgeInsets.all(3),
                child: InkWell(
                  onTap: (){
                    print("GLTV");
                    tab_index = 4;
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                  },
                  child: Text(
                    "GLTV",
                    style: TextStyle(
                        fontFamily: "phenomena-bold",
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.all(5)),
              //Logout
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(3),
                  child: InkWell(
                    onTap: ()async{
                      print("Logout");
                      user_id = null;
                      await StateWidget.of(context).logOutUser();
                      Navigator.pushNamed(context, "/home");
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(
                          fontFamily: "phenomena-bold",
                          fontSize: 34,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),


              //Cancel Account
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(3),
                  child: InkWell(
                    onTap: (){
                      print("Cancel Account");
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel Account",
                      style: TextStyle(
                          fontFamily: "phenomena-bold",
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}