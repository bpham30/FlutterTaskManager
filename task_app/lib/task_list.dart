import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/login_signup.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        actions: [
          TextButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Logout', style: TextStyle(color: Colors.red)),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
        ),
          ),
        ],
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Task input field
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter task name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)), 
                        ),
                
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Add Task button
                ElevatedButton(
                  onPressed: () {
                    // Add task to Firebase logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('Add Task', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task['name'],
                    style: TextStyle(
                      decoration: task['isCompleted']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task['isCompleted'],
                    onChanged: (value) {
                      // Update completion status in Firebase
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Delete task from Firebase
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
