import 'package:flutter/material.dart';
import 'package:todo_app/Constants/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todo_app/models/todo.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Task> myTodos = [];
  bool isLoading = false;

  // Fetch data from the API
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(api));
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          myTodos = List<Task>.from(data.map((item) => Task.fromJson(item)));
        });
      } else {
        debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error: $e");
    }
  }

  // Add a new ToDo item
  Future<void> addNewTodoToAPI(String title, String desc) async {
    try {
      final response = await http.post(
        Uri.parse(api),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'desc': desc,
          'isdone': false,
        }),
      );

      if (response.statusCode == 201) {
        fetchData();
      } else {
        debugPrint(
            'Failed to add new ToDo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Update the "isdone" status of a task
  Future<void> updateTaskStatus(Task todo, bool updatedStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$api/${todo.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isdone': updatedStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          todo.isdone = updatedStatus;
        });
      } else {
        debugPrint(
            'Failed to update task status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error updating task status: $e");
    }
  }

  // Delete a task
  Future<void> deleteTaskFromAPI(int taskId, int index) async {
    try {
      final response = await http.delete(Uri.parse('$api/$taskId/'));

      if (response.statusCode == 204) {
        setState(() {
          myTodos.removeAt(index);
        });
      } else {
        debugPrint(
            'Failed to delete task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }

  // Show a dialog to confirm deletion
  void showDeleteConfirmationDialog(Task todo, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: Text("Do you really want to delete '${todo.title}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteTaskFromAPI(todo.id, index);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // Show a dialog to add a new ToDo
  void showAddTodoDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New ToDo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();

                if (title.isNotEmpty && desc.isNotEmpty) {
                  addNewTodoToAPI(title, desc);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My ToDo List',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 5,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: const Icon(Icons.list_alt, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myTodos.isEmpty
              ? const Center(
                  child: Text(
                    "No ToDos Available!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: myTodos.length,
                    itemBuilder: (BuildContext context, int index) {
                      final todo = myTodos[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onLongPress: () {
                            showDeleteConfirmationDialog(todo, index);
                          },
                          title: Text(
                            todo.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(todo.desc),
                          trailing: IconButton(
                            icon: Icon(
                              todo.isdone
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: todo.isdone ? Colors.green : Colors.red,
                            ),
                            onPressed: () {
                              updateTaskStatus(todo, !todo.isdone);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTodoDialog,
        backgroundColor: const Color(0xFF0083B0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
