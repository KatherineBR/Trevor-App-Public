import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SettingsDrawer extends StatelessWidget {
  final bool isDefaultTheme;
  final Function(bool) onThemeChanged;

  const SettingsDrawer({
    super.key,
    required this.onThemeChanged,
    required this.isDefaultTheme,
  });

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
            // Switch is ON when NOT using default theme
            value: !isDefaultTheme,
            onChanged: (_) {
              // Just call the toggle function
              onThemeChanged(false);
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
