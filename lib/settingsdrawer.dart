import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsDrawer extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const SettingsDrawer({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  late bool isDefaultTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Compare with the theme from AppTheme.getTheme() instead of hardcoding
    final defaultThemeColor = AppTheme.getTheme().primaryColor;
    isDefaultTheme = Theme.of(context).primaryColor != defaultThemeColor;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(color: theme.colorScheme.primary),
          ),
          SwitchListTile(
            title: Text(localizations.theme),
            value: isDefaultTheme,
            onChanged: (bool newValue) {
              setState(() {
                isDefaultTheme = newValue;
              });
              widget.onThemeChanged(newValue);
            },
          ),
          ListTile(
            title: Text(localizations.contactUs),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewApp(url: 'https://www.thetrevorproject.org/contact-us/'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}