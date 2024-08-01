import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.editFunction,
    required this.enableSlidable,
  });

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final Function(BuildContext)? editFunction;
  final bool enableSlidable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 0,
      ),
      child: enableSlidable
          ? Slidable(
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  if (editFunction != null)
                    SlidableAction(
                      onPressed: editFunction,
                      icon: deleteFunction != null ? Icons.edit : Icons.restore,
                      borderRadius: BorderRadius.circular(15),
                      backgroundColor: deleteFunction != null
                          ? const Color.fromARGB(255, 0, 10, 155)
                          : Colors.green,
                    ),
                  if (deleteFunction != null)
                    SlidableAction(
                      onPressed: deleteFunction,
                      icon: Icons.delete,
                      borderRadius: BorderRadius.circular(15),
                      backgroundColor: Colors.red,
                    ),
                ],
              ),
              child: taskContainer(context),
            )
          : taskContainer(context),
    );
  }

  Widget taskContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          if (onChanged != null)
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              checkColor: Colors.pink,
              activeColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
          Text(
            taskName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              decoration: taskCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: Colors.white,
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}
