import 'package:flutter/material.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter_lab/db_helper.dart';
import 'package:flutter_lab/task_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final dbHelper = DatabaseHelper();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  List<TaskModel> tasks = [];
  bool _sortAscending = true;
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await dbHelper.initializeDatabase();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final loadedTasks = await dbHelper.getTasks();

    setState(() {
      tasks = loadedTasks;
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    try {
      await dbHelper.insertTask(TaskModel(
        title: titleController.text,
        description: descriptionController.text,
      ));
      titleController.clear();
      descriptionController.clear();
      _showCoolAlert(
          'Công việc đã được thêm thành công', CoolAlertType.success);
      await _loadTasks();
    } catch (e) {
      debugPrint('Lỗi khi thêm công việc: $e');
    }
  }

  Future<void> _updateTask(TaskModel task) async {
    try {
      await dbHelper.updateTask(task);
      _showCoolAlert(
          'Công việc đã được cập nhật thành công', CoolAlertType.success);
      await _loadTasks();
    } catch (e) {
      debugPrint('Lỗi khi cập nhật công việc: $e');
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await dbHelper.deleteTask(id);
      _showCoolAlert('Công việc đã được xóa thành công', CoolAlertType.success);
      await _loadTasks();
    } catch (e) {
      debugPrint('Lỗi khi xóa công việc: $e');
    }
  }

  Future<void> _sortTasks() async {
    tasks.sort((a, b) {
      if (_sortAscending) {
        return a.title.compareTo(b.title);
      } else {
        return b.title.compareTo(a.title);
      }
    });
    setState(() {
      _sortAscending = !_sortAscending;
    });
  }

  Future<void> _searchTasks(String keyword) async {
    if (keyword.isEmpty) {
      await _loadTasks();
    } else {
      final searchedTasks = await dbHelper.searchTasks(keyword);
      setState(() {
        tasks = searchedTasks;
      });
    }
    titleController.clear();
    descriptionController.clear();
  }

  void _showCoolAlert(
    String message,
    CoolAlertType type,
  ) {
    CoolAlert.show(
      context: context,
      type: type,
      title: 'Thông báo',
      text: message,
      confirmBtnText: 'OK',
      onConfirmBtnTap: _loadTasks,
    );
  }

  Future<void> _showDeleteConfirmationDialog(TaskModel task) async {
    await CoolAlert.show(
      context: context,
      type: CoolAlertType.confirm,
      title: 'Xác nhận',
      text: 'Bạn có chắc chắn muốn xóa công việc này không?',
      confirmBtnText: 'Xóa',
      cancelBtnText: 'Hủy',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async => await _deleteTask(task.id!),
    );
  }

  Future<void> _showTaskBottomSheet({TaskModel? task}) async {
    bool isUpdating = task != null;
    titleController.text = isUpdating ? task.title : '';
    descriptionController.text = isUpdating ? task.description : '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: keyboardHeight + 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Text(
                    isUpdating ? 'Cập nhật công việc' : 'Thêm công việc',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề',
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty ||
                          descriptionController.text.trim().isEmpty) {
                        _showCoolAlert('Vui lòng nhập đầy đủ thông tin.',
                            CoolAlertType.error);
                        return;
                      }
                      Navigator.of(context).pop();
                      if (isUpdating) {
                        await _updateTask(
                          TaskModel(
                            id: task.id,
                            title: titleController.text,
                            description: descriptionController.text,
                          ),
                        );
                      } else {
                        await _addTask();
                      }
                    },
                    child: Text(isUpdating ? 'Cập nhật' : 'Thêm'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      focusNode: searchFocusNode,
                      controller: searchController,
                      style: const TextStyle(color: Colors.grey),
                      decoration: const InputDecoration(
                          hintText: 'Tìm kiếm...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                      onChanged: (value) {
                        _searchTasks(value);
                      },
                    ),
                  ),
                ],
              )
            : const Text('Quản lý công việc'),
        actions: [
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.sort), onPressed: _sortTasks),
          IconButton(
            icon: _isSearching
                ? const Icon(Icons.clear)
                : const Icon(Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  searchController.clear();
                  _searchTasks('');
                }
                _isSearching = !_isSearching;
                if (_isSearching) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    FocusManager.instance.primaryFocus!.unfocus();
                    searchFocusNode.requestFocus();
                  });
                } else {
                  _loadTasks();
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showTaskBottomSheet();
          await _loadTasks();
        },
        tooltip: 'Thêm công việc',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildTaskList(),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return const Center(child: Text('Không có công việc'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text('${index + 1}. ${task.title}'),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await _showTaskBottomSheet(task: task);
                    await _loadTasks();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _showDeleteConfirmationDialog(task);
                    await _loadTasks();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
