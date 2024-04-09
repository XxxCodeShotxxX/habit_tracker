import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_db.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/theme/theme_provider.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HabitDB.initialize();
  await HabitDB().saveFirstLaunchDate();

  runApp(MultiProvider(
    providers: [
      //theme
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      //database
      ChangeNotifierProvider(
        create: (context) => HabitDB(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habits',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePage(),
      
    );
  }
}
