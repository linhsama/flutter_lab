import 'package:flutter/material.dart';
import 'package:flutter_lab/api/api_service.dart';
import 'package:flutter_lab/api/post_model.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late Future<List<PostModel>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = ApiService().fetchPosts();
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post List'),
      ),
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có post.'),
            );
          } else {
            List<PostModel> posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      posts[index].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      posts[index].body,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Đã chọn ${posts[index].title}"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    leading: const Icon(Icons.star),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showToast(context, "Edit ${posts[index].title}");
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showToast(context, "Delete ${posts[index].title}");
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            _showToast(context, "View ${posts[index].title}");
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
