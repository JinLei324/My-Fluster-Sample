import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:firebase_database/firebase_database.dart';

class MyShining extends StatefulWidget {

  @override
  _MyShiningState createState() => new _MyShiningState();
}

class _MyShiningState extends State<MyShining> {

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        Navigator.pop(context,"cancel");
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: (){
            return null;
          },
          child: Container(
              child: Center(
                  child: Container(
                    width: 100,
                    height: 160,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height-230,
                    ),

                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                  Navigator.pop(context,"upload");
                                },
                                highlightColor: Colors.grey,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 15,
                                      bottom: 15
                                  ),
                                  child: Text("Upload",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, right: 5),
                                color: Colors.grey,
                                height: 2,
                              ),
                              Container(height: 10,),
                              StreamBuilder(
                                stream: FirebaseDatabase.instance.reference().child("video").orderByChild("isStreaming").equalTo(true).onValue,
                                builder: (context, snap){
                                  Widget widget = Container();
                                  int shining_count = 0;
                                  if (snap.hasData && !snap.hasError && snap.data.snapshot.value!=null){
                                    Map data = snap.data.snapshot.value;
                                    data.forEach((key, value){
                                      shining_count++;
                                    });
                                    widget = Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                          left: 4,
                                          right: 4
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text("$shining_count",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    );
                                    print("----------$data--------------");
                                  }
                                  return InkWell(
                                      onTap: (){
                                        if(shining_count==0){
                                          Navigator.pop(context,"no_shine");
                                        }else{
                                          Navigator.pop(context,"shine");
                                        }
                                      },
                                      highlightColor: Colors.grey,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Stack(
                                            alignment: Alignment(2, -1.5),
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text("Start",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16
                                                    ),
                                                  ),
                                                  Text("Shine",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              widget
                                            ],
                                          )
                                        ],
                                      )
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        ClipPath(
                          clipper: TriangleClipper(),
                          child: Container(
                            width: 75,
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.white,
                                    width: 2
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              )
          ),
        )
      ),
    );
  }
}



