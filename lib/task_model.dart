class TaskModel {
  int? id; // ID của công việc, có thể là null nếu chưa có ID
  String title; // Tiêu đề của công việc
  String description; // Mô tả của công việc

  // Hàm khởi tạo có thể nhận ID, tiêu đề, và mô tả khi tạo một đối tượng TaskModel
  TaskModel({this.id, required this.title, required this.description});

  // Phương thức chuyển đổi dữ liệu từ đối tượng TaskModel thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  // Phương thức factory để tạo đối tượng TaskModel từ một Map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }
}
