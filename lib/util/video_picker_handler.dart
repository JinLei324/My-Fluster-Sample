import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:groomlyfe/ui/widgets/video_picker_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class VideoPickerHandler {
   CustomVideoPickerDialog videoPicker;
  AnimationController _controller;
  VideoPickerListner _listener;

  VideoPickerHandler(this._listener, this._controller);

  openCamera() async {
    videoPicker.dismissDialog();
    var video = await ImagePicker.pickVideo(source: ImageSource.camera);
    _listener.userVideo(video);
  }

  openGallery() async {
    videoPicker.dismissDialog();
    var video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    _listener.userVideo(video);
  }

  void init() {
    videoPicker = new CustomVideoPickerDialog(this, _controller);
    videoPicker.initState();
  }


  showDialog(BuildContext context) {
    videoPicker.getImage(context);
  }
}

abstract class VideoPickerListner {
  userVideo(File _video);
}