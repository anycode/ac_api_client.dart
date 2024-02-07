import 'dart:convert';

import 'package:ac_dart/ac_dart.dart';
import 'package:cancellation_token_http/http.dart' as http;

import 'model/api_exception.dart';
import 'model/paged.dart';

extension ResponseExt on http.Response {

  /// Decodes [Response] as JSON [Map] and converts it to a [T] object
  ///
  /// E.g. [var person = respnse.toObject<Person>(Person.fromJson)] (tear-off constructor) or
  /// [var person = respnse.toObject<Person>((json) => Person.fromJson(json)] (constructor)
  T jsonBodyToObject<T>(T Function(Map<String, dynamic> json) converter) {
    return jsonBodyToObject2<T, Map<String, dynamic>>(converter);
  }

  /// Decodes [Response] as JSON and converts it to a [T] object.
  /// JSON can be of any type [S], not only [Map], so it can be used
  /// for converting to primitive types
  ///
  /// E.g. [var intVal = response.toObject2<int, String>(int.parse)] (tear-off method) or
  /// [var intVal = response.toObject2<int, String>((str) => int.parse(str))] (function)
  T jsonBodyToObject2<T, S>(T Function(S json) converter) {
    try {
      return converter(json.decodeBytes(bodyBytes));
    } catch (e) {
      rethrow;
    }
  }

  /// Decodes [Response] as JSON array and converts it to a [List] of [T] objects
  ///
  /// E.g. [var persons = response.toList<Person>(Person.fromJson)] (tear-off constructor) or
  /// [var persons = response.toList<Person>((json) => Person.fromJson(json)] (constructor)
  List<T> jsonBodyToList<T>(T Function(Map<String, dynamic> json) converter) {
    return jsonBodyToList2<T, Map<String, dynamic>>(converter);
  }

  /// Decodes [Response] as JSON and converts it to a [List] of [T] object.
  /// JSON can be of any type [S], not only [Map], so it can be used
  /// for converting to primitive types
  ///
  /// E.g. [var intVals = response.toList2<int, String>(int.parse)] (tear-off method) or
  /// [var intVals = response.toList2<int, String>((str) => int.parse(str))] (function)
  List<T> jsonBodyToList2<T, S>(T Function(S json) converter) {
    try {
      final data = json.decodeBytes(bodyBytes);
      if (data is List) {
        return List.of(data).cast<S>().map((e) => converter(e)).toList();
      } else {
        throw ApiException(500, 'Invalid list response', null);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Decodes [Response] as JSON and converts it to a [Paged] object of [T] objects.
  ///
  /// E.g. [var persons = response.toPaged<Person>(Person.fromJson)] (tear-off constructor) or
  /// [var persons = response.toPaged<Person>((json) => Person.fromJson(json)] (constructor)
  Paged<T> jsonBodyToPaged<T>(T Function(Map<String, dynamic> json) converter) {
    return jsonBodyToPaged2<T, Map<String, dynamic>>(converter);
  }

  /// Decodes [Response] as JSON and converts it to a [Paged] object of [T] objects.
  /// JSON can be of any type [S], not only [Map], so it can be used
  /// for converting to primitive types
  ///
  /// E.g. [var intVals = response.toPaged2<int, String>(int.parse)] (tear-off method) or
  /// [var intVals = response.toPaged2<int, String>((str) => int.parse(str))] (function)
  Paged<T> jsonBodyToPaged2<T, S>(T Function(S json) converter) {
    try {
      final data = json.decodeBytes(bodyBytes);
      if (data is Map<String, dynamic>) {
        final paged = Paged<T>.fromJson(data);
        paged.data = List.of(data['data']).cast<S>().map((e) {
          print('element $e');
          return converter(e);
        }).toList();
        print(paged);
        return paged;
      } else {
        throw ApiException(500, 'Invalid paged response', null);
      }
    } catch (e) {
      rethrow;
    }
  }

}
