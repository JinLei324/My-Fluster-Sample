import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ToastShow {
  ToastShow(this.msg, this.context, this.textcolor);
  Color textcolor;
  String msg;
  BuildContext context;
  init() {
    Toast.show(msg, context,
        textColor: textcolor,
        backgroundColor: Colors.white,
        backgroundRadius: 1,
        border: Border.all(color: Colors.black, width: 1),
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM);
  }
}
