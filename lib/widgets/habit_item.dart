import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitItem extends StatelessWidget {
  const HabitItem(
      {super.key,
      required this.isCompleted,
      required this.habitName,
      this.onChanged,
      this.editHabit,
      this.deleteHabit});
  final bool isCompleted;
  final String habitName;

  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Slidable(
        endActionPane: ActionPane(motion: const StretchMotion(), children: [
          //edit Button
          SlidableAction(
            borderRadius: BorderRadius.circular(8),
            onPressed: editHabit,
            backgroundColor: Colors.grey.shade800,
            icon: Icons.edit,
          ),
          SlidableAction(
            borderRadius: BorderRadius.circular(8),
            onPressed: deleteHabit,
            backgroundColor: Colors.red,
            icon: Icons.delete,
          )
        ]),
        child: GestureDetector(
          onTap: () {
            if (onChanged != null) {
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary),
            child: ListTile(
              title: Text(
                habitName,
                style: TextStyle(
                    color: isCompleted
                        ? Colors.white
                        : Theme.of(context).colorScheme.inversePrimary),
              ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
