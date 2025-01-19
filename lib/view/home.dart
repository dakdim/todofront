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

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      http.Response response = await http.get(Uri.parse(api));
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
        // Successfully added, refresh the list
        fetchData();
      } else {
        debugPrint(
            'Failed to add new ToDo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

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
        title: const Text('My ToDo List'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 5,
        leading: const Icon(Icons.list_alt),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            todo.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(todo.desc),
                          trailing: Icon(
                            todo.isdone
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: todo.isdone ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTodoDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
