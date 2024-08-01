import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:daily_dash/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  late Box toDoBox;
  List<List<dynamic>> toDoList = [];
  List<List<dynamic>> completedList = [];
  List<List<dynamic>> deletedList = [];
  String currentSection = 'Todo';

  @override
  void initState() {
    super.initState();
    toDoBox = Hive.box('todoBox');
    loadData();
  }

  void loadData() {
    List<dynamic>? todos = toDoBox.get('todos');
    if (todos != null) {
      toDoList = List<List<dynamic>>.from(todos);
    }
    List<dynamic>? completed = toDoBox.get('completed');
    if (completed != null) {
      completedList = List<List<dynamic>>.from(completed);
    }
    List<dynamic>? deleted = toDoBox.get('deleted');
    if (deleted != null) {
      deletedList = List<List<dynamic>>.from(deleted);
    }
  }

  void saveData() {
    toDoBox.put('todos', toDoList);
    toDoBox.put('completed', completedList);
    toDoBox.put('deleted', deletedList);
  }

  void checkBoxChanged(int index) {
    setState(() {
      if (currentSection == 'Todo') {
        bool isChecked = toDoList[index][1];
        if (isChecked) {
          toDoList[index][1] = false;
        } else {
          toDoList[index][1] = true;
          completedList.add(toDoList[index]);
          toDoList.removeAt(index);
        }
      } else if (currentSection == 'Completed') {
        bool isChecked = completedList[index][1];
        if (!isChecked) {
          completedList[index][1] = true;
        } else {
          completedList[index][1] = false;
          toDoList.add(completedList[index]);
          completedList.removeAt(index);
        }
      }
      saveData();
    });
  }

  void saveNewTask() {
    setState(() {
      toDoList.add([_controller.text, false]);
      _controller.clear();
      saveData();
    });
  }

  void deleteTask(int index) {
    setState(() {
      if (currentSection == 'Todo') {
        deletedList.add(toDoList[index]);
        toDoList.removeAt(index);
      } else if (currentSection == 'Completed') {
        deletedList.add(completedList[index]);
        completedList.removeAt(index);
      }
      saveData();
    });
  }

  void restoreTask(int index) {
    setState(() {
      toDoList.add(deletedList[index]);
      deletedList.removeAt(index);
      saveData();
    });
  }

  void editTask(int index, String newTitle) {
    setState(() {
      if (currentSection == 'Todo') {
        toDoList[index][0] = newTitle;
        saveData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> currentList;
    if (currentSection == 'Todo') {
      currentList = toDoList;
    } else if (currentSection == 'Completed') {
      currentList = completedList;
    } else {
      currentList = deletedList;
    }

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text('Daily Dash'),
            ),
          ],
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    currentSection = 'Todo';
                  });
                },
                child: const Text(
                  'Todo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentSection = 'Completed';
                  });
                },
                child: const Text(
                  'Completed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentSection = 'Deleted';
                  });
                },
                child: const Text(
                  'Deleted',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: currentList.length,
        itemBuilder: (BuildContext context, index) {
          return TodoList(
            taskName: currentList[index][0] as String,
            taskCompleted: currentList[index][1] as bool,
            onChanged: currentSection != 'Deleted'
                ? (value) => checkBoxChanged(index)
                : null,
            deleteFunction: currentSection == 'Todo'
                ? (context) => deleteTask(index)
                : null,
            editFunction: currentSection == 'Todo'
                ? (context) {
                    TextEditingController editController =
                        TextEditingController();
                    editController.text = currentList[index][0] as String;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.pink.shade400,
                          title: const Text(
                            'Edit Task',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: editController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              hintText: 'Edit Task',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                editTask(index, editController.text);
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                : currentSection == 'Deleted'
                    ? (context) => restoreTask(index)
                    : null,
            enableSlidable: currentSection != 'Completed',
          );
        },
      ),
      floatingActionButton: currentSection == 'Todo'
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Add a new to-do task',
                          filled: true,
                          fillColor: Colors.pink.shade100,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.pink,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.pink,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.pink,
                    onPressed: saveNewTask,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
