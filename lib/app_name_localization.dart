import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  final configFile = File('app_names.yaml');
  if (!configFile.existsSync()) {
    print('Configuration file app_names.yaml not found.');
    return;
  }

  final config = loadYaml(configFile.readAsStringSync());
  final defaultName = config['default'] ?? 'My App';
  final locales = config['locales'] as Map;

  // Generate Android strings.xml files
  locales.forEach((locale, name) {
    final folderName = locale == 'en' ? 'values' : 'values-$locale';
    final dir = Directory('android/app/src/main/res/$folderName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final file = File('${dir.path}/strings.xml');
    file.writeAsStringSync('''
<resources>
    <string name="app_name">$name</string>
</resources>
    ''');
  });

  // Generate iOS InfoPlist.strings files
  locales.forEach((locale, name) {
    final dir = Directory('ios/Runner/$locale.lproj');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final file = File('${dir.path}/InfoPlist.strings');
    file.writeAsStringSync('''
"CFBundleDisplayName" = "$name";
    ''');
  });

  print('Localized app name files generated successfully.');
}
