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
  // print("loading.."),

  Future<void> fetchData() async {
    isLoading = true;
    setState(() {
      isLoading = true;
      print("loading ............................");
    });

    try {
      http.Response response = await http.get(Uri.parse(api));
      print("loading ............................");
      isLoading = false;
      setState(() {});

      print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          myTodos = List<Task>.from(data.map((item) => Task.fromJson(item)));
        });
      } else {
        debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
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
        title: const Text('ToDo App'),
        centerTitle: true,
      ),
      body: myTodos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: myTodos.length,
              itemBuilder: (BuildContext context, int index) {
                final todo = myTodos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.desc),
                  trailing: Icon(
                    todo.isdone ? Icons.check_circle : Icons.circle_outlined,
                    color: todo.isdone ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
    );
  }
}
