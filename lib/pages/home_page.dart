import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_db.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/widgets/habit_item.dart';
import 'package:habit_tracker/widgets/my_heatmap.dart';
import 'package:provider/provider.dart';

import '../widgets/c_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDB>(context, listen: false).readHabits();
    super.initState();
  }

  void checkOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDB>().updateHabitState(habit.id, value);
    }
  }

  bool isHabitCompletedToday(List<DateTime> completedDays) {
    final today = DateTime.now();
    return completedDays.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  final TextEditingController txtcontroller = TextEditingController();

  void editHabitBox(Habit habit) {
    txtcontroller.text = habit.name;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: TextField(
                controller: txtcontroller,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newhabitName = txtcontroller.text;
                    context
                        .read<HabitDB>()
                        .updateHabitName(habit.id, newhabitName);
                    Navigator.pop(context);
                    txtcontroller.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    txtcontroller.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  void deleteHabitBox(Habit habit) {
    txtcontroller.text = habit.name;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Are you sure you want to delete this habit?"),
              actions: [
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDB>().deleteHabit(habit.id);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    txtcontroller.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: TextField(
                controller: txtcontroller,
                decoration:
                    const InputDecoration(hintText: 'Add a new habit !!'),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newhabitName = txtcontroller.text;
                    context.read<HabitDB>().addHabit(newhabitName);
                    Navigator.pop(context);
                    txtcontroller.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    txtcontroller.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const cDrawer(),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: createNewHabit,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: ListView(children: [_buildHeatMap(), _buildHabitList()]),
    );
  }

  Widget _buildHeatMap() {
    final habitDataBase = context.watch<HabitDB>();

    List<Habit> currentHabits = habitDataBase.currentHabits;
    return FutureBuilder<DateTime?>(
        future: habitDataBase.getFirstLaunchDate(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepareDatasets(currentHabits),
            );
          } else {
            return Container(
              height: 50,
              width: double.infinity,
              child: Center(child: Text(snapshot.error.toString())),
            );
          }
        }));
  }

  Widget _buildHabitList() {
    final habitDataBase = context.watch<HabitDB>();

    List<Habit> currentHabits = habitDataBase.currentHabits;
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          final habit = currentHabits[index];
          bool isCompleted = isHabitCompletedToday(habit.completed);
          return HabitItem(
            habitName: habit.name,
            isCompleted: isCompleted,
            onChanged: (value) => checkOnOff(value, habit),
            editHabit: (value) => editHabitBox(habit),
            deleteHabit: (value) => deleteHabitBox(habit),
          );
        });
  }
}

Map<DateTime, int> prepareDatasets(List<Habit> habits) {
  Map<DateTime, int> datasets = {};
  for (var habit in habits) {
    for (var date in habit.completed) {
      final normalizeDate = DateTime(date.year, date.month, date.day);
      if (datasets.containsKey(normalizeDate)) {
        datasets[normalizeDate] = datasets[normalizeDate]! + 1;
      } else {
        datasets[normalizeDate] = 1;
      }
    }
  }

  return datasets;
}
