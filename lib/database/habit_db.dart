import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDB extends ChangeNotifier {
  static late Isar isar;

  // initialize

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([AppSettingsSchema, HabitSchema], directory: dir.path);
  }

  // save first launch Date
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();

    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunch = DateTime.now();
      await isar
          .writeTxn(() => isar.appSettings.put(settings) // insert & update
              );
    }
  }

  //Get first date of startup
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunch;
  }

  //C R U D
  // Create
  List<Habit> currentHabits = [];
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;
    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabits();
  }

  //Read
  Future<void> readHabits() async {
    //fetch all habits
    List<Habit>? fetchedhabits = await isar.habits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(fetchedhabits);
    notifyListeners();
  }

  //Update
  // habit state
  Future<void> updateHabitState(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completed.contains(DateTime.now())) {
          final today = DateTime.now();
          habit.completed.add(DateTime(today.year, today.month, today.day));
        } else {
          habit.completed.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        // save updated habits
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  //edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  //DELETE
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabits();
  }
}
