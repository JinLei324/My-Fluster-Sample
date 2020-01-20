import 'package:thumbnails/thumbnails.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GetThumbnails{
  Future<File> getThumbnailsImage(videoPathUrl) async {
    try{
      var appDocDir = await getApplicationDocumentsDirectory();
      final folderPath = appDocDir.path;
      String thumb = await Thumbnails.getThumbnail(
          thumbnailFolder: folderPath,
          videoFile: videoPathUrl,
          imageType: ThumbFormat.PNG,//this image will store in created folderpath
          quality: 30);
      print(thumb);
      return File(thumb);
    }catch(e){
      print(e.toString());
    }

  }
}