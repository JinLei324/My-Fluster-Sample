import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as Path;
import 'dart:math';
import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';
import 'package:amazon_s3_cognito/aws_region.dart';
class Storage{
  static final Storage _instance =
  new Storage.internal();
  String random_path = Random().nextInt(1000000000).toString();

  Storage.internal();

  factory Storage() {
    return _instance;
  }

   Future<String> uploadFile(File file,String path_url)async {
    if(file == null){
      return "";
    }
    print(Path.basename(file.path));
    String photoUrl="";
    String imagePath = "Files/$path_url/$random_path${Path.basename(file.path)}";
    photoUrl = await AmazonS3Cognito.upload(file.path, "groomly", "ap-northeast-1:e869d061-eceb-4c1f-843e-6c716f16fe6e", imagePath, AwsRegion.AP_NORTHEAST_1, AwsRegion.AP_NORTHEAST_1);
    print(photoUrl);
    return  photoUrl;
   }
}