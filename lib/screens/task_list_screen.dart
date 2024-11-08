import 'package:flutter/material.dart';
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

    if (response.success && response.results != null) {
      setState(() {
        _tasks = response.results as List<ParseObject>;
      });
    } else {
      print("Failed to fetch tasks: ${response.error?.message}");
    }
  }

  // Add a new task to the database
  Future<void> addTask(String title) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser != null) {
      final task = ParseObject('Task')
        ..set('title', title)
        ..set('completed', false)
        ..set('user', currentUser);

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
  Future<void> editTask(ParseObject task, String newTitle) async {
    setState(() {
      task.set('title', newTitle); // Update title locally
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
  Future<String?> _showTaskDialog({String? currentTitle}) async {
    String? taskTitle = currentTitle;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentTitle == null ? 'Add New Task' : 'Edit Task'),
          content: TextField(
            onChanged: (value) => taskTitle = value,
            controller: TextEditingController(text: currentTitle),
            decoration: InputDecoration(hintText: "Enter task title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, taskTitle),
              child: Text("Save"),
            ),
          ],
        );
      },
    );
    return taskTitle;
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
          return Dismissible(
            key: ValueKey(task.objectId),
            background: Container(
              color: Colors.amberAccent,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Edit task on right swipe
                final newTitle = await _showTaskDialog(
                    currentTitle: task.get<String>('title'));
                if (newTitle != null && newTitle.isNotEmpty) {
                  await editTask(task, newTitle);
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
          final title = await _showTaskDialog();
          if (title != null && title.isNotEmpty) {
            await addTask(title); // Add task and refresh the list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
