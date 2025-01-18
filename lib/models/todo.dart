class Task {
  int id;
  String title;
  String desc;
  bool isdone;
  String date;
  Task({
    required this.id,
    required this.title,
    required this.desc,
    required this.isdone,
    required this.date,
  });

  static fromJson(item) {}
}
