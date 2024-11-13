import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_app/login_signup.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  //task input controller
  final TextEditingController _taskController = TextEditingController();

  //init firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //init firebase user
  final User _user = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  //funct to add task to firestore
  Future<void> _addTask(String taskName) async {
    //check if task name is not empty
    if (taskName.isNotEmpty && _user != null) {
      //add task to firestore
      await _firestore.collection('tasks').add({
        //task data
        'name': taskName,
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _user.uid,
      });
      //clear task input field
      _taskController.clear();
    }
  }

  //func to delete task
  Future<void> _deleteTask(String taskId) async {
    //delete
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  //func to update task completion
  Future<void> _completeTask(String taskId, bool isCompleted) async {
    //update
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AuthScreen()));
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
                //task input
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
                //add task btn
                ElevatedButton(
                  onPressed: () {
                    _addTask(_taskController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          //task list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Stream for tasks filtered by userId
              stream: _firestore
                  .collection('tasks')
                  .where('userId', isEqualTo: _user.uid)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                //loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                //error
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading tasks. Please log out and try again."));
                }
                //no tasks found
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No tasks found"));
                }
                //tasks found
                final tasks = snapshot.data!.docs;

                //task list
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    //task data
                    final task = tasks[index];
                    final taskData = task.data() as Map<String, dynamic>;
                    final taskId = task.id;
                    final taskName = taskData['name'];
                    final isCompleted = taskData['isCompleted'];

                    //task list tile
                    return ListTile(
                      title: Text(
                        taskName,
                        style: TextStyle(
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      //complete task check
                      leading: Checkbox(
                        value: isCompleted,
                        onChanged: (value) => _completeTask(taskId, value!),
                      ),
                      //delete task btn
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(taskId),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
