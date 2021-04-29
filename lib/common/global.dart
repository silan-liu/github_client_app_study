import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_client_app_study/models/cacheConfig.dart';
import 'package:github_client_app_study/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';

const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

class Global {
  static SharedPreferences _prefs;
  static Profile profile = Profile();

  // 网络缓存
  static NetCache netCache = NetCache();

  // 主题列表
  static List<MaterialColor> get themes => _themes;

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  // 全局初始化
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    _prefs = await SharedPreferences.getInstance();

    // 获取本地缓存的信息
    var _profile = _prefs.getString("profile");
    if (_profile != null) {
      try {
        var json = jsonDecode(_profile);
        profile = Profile.fromJson(json);
      } catch (e) {
        print(e);
      }
    }

    // 缓存策略，若没有则设置默认值
    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // 初始化网络请求
    Git.init();
  }

  // 保存到本地
  static saveProfile() {
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }
}
