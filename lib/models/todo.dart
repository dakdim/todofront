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

  // Implement the fromJson method to map the data from the API response
  factory Task.fromJson(Map<String, dynamic> item) {
    return Task(
      id: item['id'],
      title: item['title'],
      desc: item['desc'],
      isdone: item['isdone'],
      date: item['date'],
    );
  }
}
