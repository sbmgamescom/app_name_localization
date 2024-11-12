// lib/app_name_localization.dart

import 'dart:io';

import 'package:yaml/yaml.dart';

void generateLocalizedAppNames() {
  final configFile = File('app_names.yaml');
  if (!configFile.existsSync()) {
    print('Configuration file app_names.yaml not found.');
    return;
  }

  final config = loadYaml(configFile.readAsStringSync());
  final defaultName = config['default'] ?? 'My App';
  final locales = config['locales'] as Map;
  final platforms = (config['platforms'] as YamlMap?)
          ?.map((key, value) => MapEntry(key.toString(), value == true)) ??
      {'android': true, 'ios': true};

  if (platforms['android'] == true) {
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
    <string name="app_name">${name ?? defaultName}</string>
</resources>
    ''');
    });

    // Update AndroidManifest.xml with android:label="@string/app_name"
    final androidManifest = File('android/app/src/main/AndroidManifest.xml');
    if (androidManifest.existsSync()) {
      String manifestContent = androidManifest.readAsStringSync();
      final labelPattern = RegExp(r'android:label="[^"]*"');
      if (labelPattern.hasMatch(manifestContent)) {
        manifestContent = manifestContent.replaceAll(
            labelPattern, 'android:label="@string/app_name"');
      }

      androidManifest.writeAsStringSync(manifestContent);
      print(
          'AndroidManifest.xml updated with android:label="@string/app_name".');
    } else {
      print('AndroidManifest.xml not found.');
    }
  }
  if (platforms['ios'] == true) {
    // Generate iOS InfoPlist.strings files
    locales.forEach((locale, name) {
      final dir = Directory('ios/Runner/$locale.lproj');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('${dir.path}/InfoPlist.strings');
      file.writeAsStringSync('''
"CFBundleDisplayName" = "${name ?? defaultName}";
    ''');
    });
  }
  print('Localized app name files generated successfully.');
}
