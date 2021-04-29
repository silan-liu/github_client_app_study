import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../index.dart';

class Git {
  Git([this.context]) {
    _options = Options(extra: {"context": context});
  }

  BuildContext context;
  Options _options;

  static Dio dio = new Dio(BaseOptions(
      baseUrl: 'https://api.github.com',
      headers: {
        HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
            "application/vnd.github.symmetra-preview+json"
      }
  ));

  static void init() {
    // 缓存插件
    dio.interceptors.add(Global.netCache);

    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;

    // 调试模式抓包调试，使用代理，禁用 https 证书校验
    if (!Global.isRelease) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          return "PROXY 10.95.249.53:8888";
        };

        // 禁用证书校验
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  Future<User> login(String login, String pwd) async {
    String basic = 'Basic' +  base64.encode(utf8.encode('$login:$pwd'));

    var r = await dio.get(
        '/users/$login',
        options: _options.merge(headers: {
          HttpHeaders.authorizationHeader: basic
        }, extra: {
          'noCache': true
        })
    );

    dio.options.headers[HttpHeaders.authorizationHeader] = basic;

    // 清空缓存
    // Global.netCache

    Global.profile.token = basic;

    return User.fromJson(r.data);
  }

  Future<List<Repo>> getRepos({Map<String, dynamic> queryParameters, refresh = false}) async {
    if (refresh) {
      _options.extra.addAll({"refresh": true, "list": true});
    }

    var r = await dio.get<List>(
      'user/repos',
        queryParameters: queryParameters,
      options: _options
    );

    return r.data.map((e) => Repo.fromJson(e)).toList();
  }
}