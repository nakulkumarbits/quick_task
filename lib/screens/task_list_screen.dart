import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ParseObject> _tasks = [];

  // Fetch tasks associated with the current user
  Future<void> _fetchTasks() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('user', currentUser);

    final response = await query.query();

    if (response.success) {
      if (response.results != null) {
        setState(() {
          _tasks = response.results as List<ParseObject>;
        });
      } else {
        print("Response : ${response.error?.message}");
      }
    } else {
      print("Failed to fetch tasks: ${response.error?.message}");
    }
  }

  // Add a new task to the database
  Future<void> addTask(String title, DateTime? dueDate) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser != null) {
      final task = ParseObject('Task')
        ..set('title', title)
        ..set('completed', false)
        ..set('user', currentUser)
        ..set('dueDate', dueDate); // Set due date if provided

      final response = await task.save();
      if (response.success) {
        print("Task added successfully!");
        _fetchTasks(); // Refresh the task list after adding
      } else {
        print("Error adding task: ${response.error?.message}");
      }
    }
  }

  // Edit an existing task
  Future<void> editTask(
      ParseObject task, String newTitle, DateTime? newDueDate) async {
    setState(() {
      task.set('title', newTitle);
      task.set('dueDate', newDueDate); // Update title duedate locally
    });

    final response = await task.save();
    if (!response.success) {
      print("Error editing task: ${response.error?.message}");
      _fetchTasks(); // Re-fetch tasks in case of error
    }
  }

  // Delete a task from the database and remove it from the UI
  Future<void> deleteTask(ParseObject task) async {
    setState(() {
      _tasks.remove(task); // Remove the task from the list immediately
    });

    final response = await task.delete();
    if (!response.success) {
      print("Error deleting task: ${response.error?.message}");
      _fetchTasks(); // Re-fetch tasks in case of error
    }
  }

  // Log out the current user
  Future<void> _logout() async {
    final response = await ParseUser.currentUser() as ParseUser?;
    if (response != null) {
      await response.logout();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // Show dialog to add or edit a task
  Future<Map<String, dynamic>?> _showTaskDialog(
      {String? currentTitle, DateTime? currentDueDate}) async {
    String? taskTitle = currentTitle;
    DateTime? taskDueDate = currentDueDate;
    TextEditingController titleController =
        TextEditingController(text: currentTitle); // Use a single controller

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(currentTitle == null ? 'Add New Task' : 'Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  // onChanged: (value) => taskTitle = value,
                  controller: titleController, // Use the retained controller
                  decoration:
                      const InputDecoration(hintText: "Enter task title"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      taskDueDate != null
                          ? "Due: ${DateFormat.yMMMd().format(taskDueDate!)}"
                          : "No due date",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: taskDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() => taskDueDate = pickedDate);
                        }
                      },
                      child: const Text("Pick Due Date"),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null); // Return null on cancel
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, {
                  'title':
                      titleController.text, // Retrieve text from controller
                  'dueDate': taskDueDate,
                }),
                child: const Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final dueDate = task.get<DateTime>('dueDate');
          return Dismissible(
            key: ValueKey(task.objectId),
            background: Container(
              color: Colors.amberAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Edit task on right swipe
                final result = await _showTaskDialog(
                  currentTitle: task.get<String>('title'),
                  currentDueDate: dueDate,
                );
                if (result != null) {
                  await editTask(task, result['title'], result['dueDate']);
                }
                return false; // Prevent actual dismissal
              } else if (direction == DismissDirection.endToStart) {
                // Confirm delete on left swipe
                return true; // Allow actual dismissal for delete
              }
              return false;
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                deleteTask(task); // Delete task if dismissed to the left
              }
            },
            child: ListTile(
              title: Text(
                task.get<String>('title') ?? 'Untitled Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  decoration: task.get<bool>('completed') ?? false
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.white,
                  decorationThickness: 2,
                ),
              ),
              subtitle: dueDate != null
                  ? Text(
                      "Due: ${DateFormat.yMMMd().format(dueDate)}",
                      style: const TextStyle(color: Colors.white70),
                    )
                  : null,
              trailing: Checkbox(
                value: task.get<bool>('completed') ?? false,
                onChanged: (bool? value) async {
                  task.set('completed', value);
                  // Save the updated task status and only refresh on success
                  final response = await task.save();
                  if (response.success) {
                    _fetchTasks(); // Refresh the task list after updating
                  } else {
                    print("Error updating task: ${response.error?.message}");
                  }
                },
                checkColor: Colors.white,
                activeColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await _showTaskDialog();
          if (result != null) {
            await addTask(result['title'],
                result['dueDate']); // Add task and refresh the list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
