import 'package:dio/dio.dart';
import 'dart:collection';
import '../index.dart';

class CacheObject {
  CacheObject(this.response):timeStamp = DateTime.now().millisecondsSinceEpoch;

  Response response;
  int timeStamp;
}

class NetCache extends Interceptor {
  
}