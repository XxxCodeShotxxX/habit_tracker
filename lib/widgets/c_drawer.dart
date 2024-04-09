import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class cDrawer extends StatelessWidget {
  const cDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Center(
        child: Switch(
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme()),
      ),
    );
  }
}
