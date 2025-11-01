import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const JewelXApp());
}
