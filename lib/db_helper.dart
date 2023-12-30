import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_lab/task_model.dart';

class DatabaseHelper {
  late Database _database;
  bool _isDatabaseInitialized = false;
  // Khởi tạo hoặc mở kết nối đến cơ sở dữ liệu SQLite
  Future<void> initializeDatabase() async {
    if (!_isDatabaseInitialized) {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'task_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT)',
          );
        },
        version: 1,
      );
      _isDatabaseInitialized = true;
    }
  }

  // Lấy danh sách tất cả các công việc từ cơ sở dữ liệu
  Future<List<TaskModel>> getTasks() async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('tasks');
    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }

  // Thêm một công việc mới vào cơ sở dữ liệu
  Future<void> insertTask(TaskModel task) async {
    await initializeDatabase();
    await _database.insert('tasks', task.toMap());
  }

  // Cập nhật thông tin của một công việc trong cơ sở dữ liệu
  Future<void> updateTask(TaskModel task) async {
    await initializeDatabase();
    await _database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Xóa một công việc khỏi cơ sở dữ liệu dựa trên ID
  Future<void> deleteTask(int id) async {
    await initializeDatabase();
    await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tìm kiếm các công việc theo từ khoá (keyword) trong tiêu đề hoặc mô tả
  Future<List<TaskModel>> searchTasks(String keyword) async {
    await initializeDatabase();
    final List<Map<String, dynamic>> maps = await _database.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );

    return List.generate(
      maps.length,
      (i) {
        return TaskModel.fromMap(maps[i]);
      },
    );
  }
}
