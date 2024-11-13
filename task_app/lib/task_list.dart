import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_app/login_signup.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  //day and time slot
  String _selectedDay = 'Monday';
  String _selectedTimeSlot = '9 am - 10 am';

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> _timeSlots = [
    '9 am - 10 am',
    '10 am - 11 am',
    '11 am - 12 pm',
    '12 pm - 1 pm',
    '1 pm - 2 pm',
    '2 pm - 3 pm',
    '3 pm - 4 pm',
    '4 pm - 5 pm'
  ];

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
  Future<void> _addTask(String taskName, String day, String timeSlot) async {
    //check if task name is not empty
    if (taskName.isNotEmpty && _user != null) {
      //add task to firestore
      await _firestore.collection('tasks').add({
        //task data
        'name': taskName,
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _user.uid,
        'day': day,
        'timeSlot': timeSlot,
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
                //dropdown day
                DropdownButton<String>(
                  value: _selectedDay,
                  items: _days.map((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (String? newDay) {
                    setState(() {
                      _selectedDay = newDay!;
                    });
                  },
                ),
                const SizedBox(width: 8),
                //dropdown time slot
                DropdownButton<String>(
                  value: _selectedTimeSlot,
                  items: _timeSlots.map((String slot) {
                    return DropdownMenuItem<String>(
                      value: slot,
                      child: Text(slot),
                    );
                  }).toList(),
                  onChanged: (String? newSlot) {
                    setState(() {
                      _selectedTimeSlot = newSlot!;
                    });
                  },
                ),
                //add task btn
                ElevatedButton(
                  onPressed: () {
                    _addTask(
                        _taskController.text, _selectedDay, _selectedTimeSlot);
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
              //get tasks
              stream: _firestore
                  .collection('tasks')
                  .where('userId', isEqualTo: _user.uid)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                //loading
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                //group tasks by day and time slot
                final tasks = snapshot.data!.docs;
                final Map<String, Map<String, List<DocumentSnapshot>>>
                    groupedTasks = {};
                //loop through tasks and group them by day and time slot
                for (var task in tasks) {
                  final taskData = task.data() as Map<String, dynamic>;
                  final day = taskData['day'] as String;
                  final timeSlot = taskData['timeSlot'] as String;

                  if (!groupedTasks.containsKey(day)) {
                    groupedTasks[day] = {};
                  }
                  if (!groupedTasks[day]!.containsKey(timeSlot)) {
                    groupedTasks[day]![timeSlot] = [];
                  }
                  groupedTasks[day]![timeSlot]!.add(task);
                }

                //display tasks
                return ListView(
                  //grouped tasks
                  children: groupedTasks.entries.map((dayEntry) {
                    final day = dayEntry.key;
                    final timeSlots = dayEntry.value;

                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(day,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: timeSlots.entries.map((timeSlotEntry) {
                        final timeSlot = timeSlotEntry.key;
                        final tasks = timeSlotEntry.value;

                        return ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(timeSlot,
                              style: TextStyle(color: Colors.grey[600])),
                          children: tasks.map((task) {
                            final taskData =
                                task.data() as Map<String, dynamic>;
                            final taskName = taskData['name'];
                            final isCompleted = taskData['isCompleted'];

                            return ListTile(
                              title: Text(
                                taskName,
                                style: TextStyle(
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              //complete task
                              leading: Checkbox(
                                value: isCompleted,
                                onChanged: (value) =>
                                    _completeTask(task.id, value!),
                              ),
                              //delete task
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTask(task.id),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
