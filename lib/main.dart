import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:printsari_sia/app.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await Hive.initFlutter();
  await Hive.openBox<String>('app_cache');
  await Supabase.initialize(
    url: "http://127.0.0.1:54321",
    anonKey: "sb_secret_N7UND0UgjKTVK-Uodkm0Hg_xSvEMPvz",
  );
  runApp(const App());
}
