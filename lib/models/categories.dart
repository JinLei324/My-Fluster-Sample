class Categories{
  String name;
  bool select_check;
  Categories({this.name, this.select_check});

  factory Categories.fromJson(Map<String, dynamic> json) => new Categories(
      name: json['name'],
      select_check: json['select_check'],
  );
}