import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import '../model/daily_update_model.dart';


class DailyUpdateProvider extends ChangeNotifier{
  DailyUpdate? _dailyUpdate;
  bool _isLoading = false;

  DailyUpdate? get dailyUpdate => _dailyUpdate;
  bool get isLoading => _isLoading;

  Future<void> fetchLatestNews() async{
    _isLoading = true;
    notifyListeners();

    try{
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.fetchAndActivate();

      final jsonString = remoteConfig.getString('cyber_security_learn_daily_topic');

      if (jsonString.isEmpty) {
        throw Exception("news_content key not found or empty in Remote Config");
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      _dailyUpdate = DailyUpdate.fromJson(data);
      print("✅ News fetched from Remote Config: ${_dailyUpdate!.title}");
      print("✅ News fetched from Remote Config: ${_dailyUpdate!.content}");
    } catch (e) {
      print("❌ Error fetching news: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}