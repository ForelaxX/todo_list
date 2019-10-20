import 'package:flutter/services.dart';
import 'package:todo_list/model/todo.dart';

class Channel {
  static const MethodChannel platform = const MethodChannel('todo_list.example.io/location');

  static Future<Location> getCurrentLocation() async {
    Map locationMap = await platform.invokeMethod<Map>('getCurrentLocation');
    return Location(latitude: double.parse(locationMap['latitude']), longitude: double.parse(locationMap['longitude']), description: locationMap['description']);
  }
}