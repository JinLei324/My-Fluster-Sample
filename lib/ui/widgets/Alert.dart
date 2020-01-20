import 'package:flutter/material.dart';

class ShowAlert{

  InfoAlert(BuildContext context, String title, String content)=>showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Text(title,),
      content: new Text(content),
      actions: <Widget>[
        new GestureDetector(
          onTap: () => Navigator.of(context).pop(false),
          child:roundedButton("OK",const Color(0xFF167F67),
              const Color(0xFFFFFFFF)),
        ),
      ],
    ),
  );
  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }


}