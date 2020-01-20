class Praise{
  String key;
  String id;
  String user_id;
  String video_id;
  bool is_following;
  bool is_praising;
  bool is_loving;
  Praise({this.key, this.id, this.user_id, this.video_id, this.is_following, this.is_praising, this.is_loving});

  toJson(){
    return {
      "id":id,
      "user_id":user_id,
      "video_id":video_id,
      "is_following":is_following,
      "is_parsing":is_praising,
      "is_loving":is_loving
    };
  }
}