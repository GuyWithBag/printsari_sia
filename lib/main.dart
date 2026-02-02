import 'package:flutter/material.dart';
import 'package:printsari_sia/app.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  setPathUrlStrategy();
  await Supabase.initialize(
    url: "https://ezfbjccvucyqzfxkyssg.supabase.co",
    anonKey: "sb_publishable_SHGoLCLSjCArcdvngMhOdw_o8FkU05i",
  );
  runApp(const App());
}

final supabase = Supabase.instance.client;
